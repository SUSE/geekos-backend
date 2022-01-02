class Crawler::Ldap < Crawler::BaseCrawler
  def run
    super

    suse_ldap_users.sort_by { |u| u['samaccountname'] }.each_with_index do |user_hash, _index|
      store_user(user_hash)
    end
    cleanup
    nil
  end

  private

  def store_user(user_hash)
    u = User.find(user_hash['employeenumber']) || User.new
    if u.new_record?
      log.info "LDAP -> New user, employeenumber: #{user_hash['employeenumber']} (#{user_hash['samaccountname']})"
    end
    attributes_before = u.attributes['ldap'].clone
    u['ldap'] = user_hash
    set_manager(u, user_hash)
    if u.changed.present?
      log.info "LDAP -> Updating user #{user_hash['samaccountname']} (#{user_hash['employeenumber']}) " \
               "#{deep_diff(attributes_before, u.attributes['ldap'])}"
    end
    Mongoid::AuditLog.record { u.save! }
    u
  end

  def set_manager(user, user_hash)
    if user_hash['manager'].present?
      manager_hash = suse_ldap_users.find { |lu| lu['cn'] == user_hash['manager'].match(/cn=(.+?),/i)[1] }
    end
    if manager_hash
      # skip CEO manager self-reference
      unless manager_hash['employeenumber'] == user_hash['employeenumber']
        manager = User.find(manager_hash['employeenumber']) || store_user(manager_hash)
        user.manager = manager
      end
    else
      user.manager = nil
      log.warn "LDAP -> Manager '#{user_hash['manager']}' not found for employee '#{user_hash['samaccountname']}'"
    end
  end

  def cleanup
    log.info 'LDAP -> nothing to cleanup' and return unless needs_cleanup?

    log.info 'LDAP -> deleting absent users from the local storage'
    raise "Too many missing users (#{users_to_cleanup.size}), LDAP issue?" if users_to_cleanup.size > 25

    users_to_cleanup.each do |user|
      log.info "LDAP -> destroying #{user.fullname}: #{user.employeenumber}"
      user.destroy!
    end
  end

  def suse_ldap_users
    @suse_ldap_users ||= ::Ldap.active_users.select { |u| u['employeenumber'].present? }
  end

  def needs_cleanup?
    log.debug "LDAP -> in LDAP tree: #{suse_ldap_users.count} entries"
    log.debug "LDAP -> locally: #{User.count} entries"
    !users_to_cleanup.empty?
  end

  def users_to_cleanup
    ldap_ids = suse_ldap_users.map { |x| x['employeenumber'] }
    User.not.in('ldap.employeenumber': ldap_ids).to_a
  end
end
