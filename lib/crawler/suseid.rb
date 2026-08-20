# Fetching user attributes from Authentik
#
# This crawler creates, updates and deletes users, and it sets their
# manager. The attributes land in `user.suseid`, where the mappings of
# the User model pick them up.
#
# API docs: https://docs.goauthentik.io/docs/developer-docs/api/
# Single user: `Crawler::Suseid.new.user_by_email('tschmidt@suse.com')`

class Crawler::Suseid < Crawler::BaseCrawler
  BASE_URL = ENV.fetch('geekos_suseid_url', 'https://id.suse.com')
  TOKEN = ENV.fetch('geekos_suseid_token', nil)
  GROUPS = %w[employees contingent-workers].freeze
  # authentik caps this at the tenant's pagination_max_page_size, 100 by default
  PAGE_SIZE = 100

  def run
    raise 'please set geekos_suseid_token to run the suseid crawler' if TOKEN.blank?

    super
    log.info "SUSEID -> Found #{users.size} SUSE ID users"
    update_users
    cleanup
    set_managers
    nil
  end

  # Active users of the employee groups, flattened and sorted by username
  def users
    @users ||= fetch_all.map { |u| user_attributes(u) }.sort_by { |u| u['username'] }
  end

  # One user of the employee groups, nil if the email is unknown there
  def user_by_email(email)
    user = get_page(1, [['email', email]])['results'].first
    user_attributes(user) if user
  end

  private

  def update_users
    users.each do |user_hash|
      user = User.find(user_hash['username']) || User.new
      log.info "SUSEID -> New user: #{user_hash['username']} (#{user_hash['email']})" if user.new_record?
      attributes_before = user.attributes['suseid'].clone
      user['suseid'] = user_hash
      if user.persisted? && user.changed.present?
        log.info "SUSEID -> Updating user #{user_hash['username']}: " \
                 "#{deep_diff(attributes_before, user.attributes['suseid'])}"
      end
      Mongoid::AuditLog.record { user.save! }
    end
  end

  # Runs after cleanup, so every user of this crawl exists and retired
  # managers are gone. No recursion needed, unlike the ldap crawler.
  def set_managers
    users.each do |user_hash|
      user = User.find(user_hash['username'])
      manager = manager_for(user_hash)
      # the ceo manages themselves
      next if user.nil? || manager == user || manager == user.manager

      log.info "SUSEID -> Manager of #{user_hash['username']}: #{user.manager&.username} -> #{manager&.username}"
      Mongoid::AuditLog.record { user.update!(manager: manager) }
    end
  end

  def manager_for(user_hash)
    uid = user_hash['managerUid']
    return if uid.blank?

    manager = User.find(uid)
    log.warn "SUSEID -> Manager '#{uid}' not found for '#{user_hash['username']}'" if manager.nil?
    manager
  end

  def cleanup
    log.debug "SUSEID -> in SUSE ID: #{users.count} entries, locally: #{User.count} entries"
    log.info 'SUSEID -> nothing to cleanup' and return if users_to_cleanup.empty?

    log.info 'SUSEID -> deleting absent users from the local storage'
    raise "Too many missing users (#{users_to_cleanup.size}), SUSE ID issue?" if users_to_cleanup.size > 75

    users_to_cleanup.each do |user|
      log.info "SUSEID -> retiring #{user.fullname}: #{user.username}"
      user.destroy!
    end
  end

  def users_to_cleanup
    @users_to_cleanup ||= User.not.in('suseid.username': users.pluck('username')).to_a
  end

  # Flatten an authentik user into the attributes geekos uses
  def user_attributes(user)
    attrs = user['attributes'] || {}
    { 'username' => user['username'],
      'email' => user['email'],
      'name' => user['name'],
      # the ldap uuid, same as attributes.ldap_uniq, not authentik's own top level uuid
      'uuid' => attrs['uuid'],
      # the api sends a timestamp, geekos keeps the date only
      'date_joined' => user['date_joined']&.to_date&.to_s,
      'title' => attrs['title'],
      'office' => attrs['office'],
      'division' => attrs['division'],
      'department' => attrs['department'],
      'costCenter' => attrs['costCenter'],
      'workLocationType' => attrs['workLocationType'],
      'employeeNumber' => attrs['employeeNumber'],
      'telephoneNumber' => attrs['telephoneNumber'],
      'country' => attrs.dig('address', 'country'),
      'managerUid' => attrs['managerUid'],
      # okta.githubUsername is a list too
      'githubUsername' => Array(attrs.dig('socialId', 'GitHub')).presence }
  end

  def fetch_all
    first = get_page(1)
    pages = first.dig('pagination', 'total_pages').to_i
    log.debug "#{pages} pages, each #{PAGE_SIZE}"
    first['results'] + (2..pages).flat_map { |page| get_page(page)['results'] }
  end

  def get_page(page, extra = [])
    url = "#{BASE_URL}/api/v3/core/users/?#{query_string(page, extra)}"
    log.debug "SUSEID -> GET #{url}"
    JSON.parse(RestClient.get(url, { Authorization: "Bearer #{TOKEN}", accept: :json }).body)
  end

  # Not RestClient's `params:`, that one encodes a list as `groups_by_name[]=`.
  # django-filter reads repeated keys and ignores the bracket form.
  def query_string(page, extra)
    URI.encode_www_form(
      GROUPS.map { |group| ['groups_by_name', group] } +
      [['is_active', true], ['include_groups', false], ['include_roles', false],
       ['page', page], ['page_size', PAGE_SIZE]] + extra
    )
  end
end
