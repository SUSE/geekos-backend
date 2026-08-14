# Fetching user attributes from Authentik
#
# This crawler only collects data. It does not create, delete or re-parent
# users, the LDAP and Okta crawlers stay in charge of that. The attributes
# land in `user.suseid` and are not mapped to any user attribute yet.
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
      user = User.find_by('ldap.mail': user_hash['email'])
      if user
        attributes_before = user.attributes['suseid'].clone
        user['suseid'] = user_hash
        if user.changed.present?
          log.info "SUSEID -> Updating user #{user.username}: " \
                   "#{deep_diff(attributes_before, user.attributes['suseid'])}"
        end
        Mongoid::AuditLog.record { user.save! }
      else
        log.debug "SUSEID -> User not found in db: #{user_hash['email']}"
      end
    end
  end

  # Flatten an authentik user into the attributes geekos uses
  def user_attributes(user)
    attrs = user['attributes'] || {}
    { 'username' => user['username'],
      'email' => user['email'],
      'name' => user['name'],
      # the ldap uuid, same as attributes.ldap_uniq, not authentik's own top level uuid
      'uuid' => attrs['uuid'],
      'date_joined' => user['date_joined'],
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
