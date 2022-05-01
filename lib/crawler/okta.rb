# Fetching user attributes from Okta

class Crawler::Okta < Crawler::BaseCrawler
  def run
    super

    # https://developer.okta.com/docs/api/resources/users#list-users
    # single user: client.get_user(user.username).first
    log.info "Okta -> Found #{okta_users.size} Okta users"
    update_users(okta_users)
    cleanup_deactivated_users(okta_users)
    nil
  end

  def okta_users
    @okta_users ||= client.list_users(paginate: true,
                                      content_type: "application/json; " \
                                                    "okta-response=omitCredentials,omitCredentialsLinks")
                          .first.to_a
                          .sort_by { |u| u.profile.email }
                          .select { |u| u.status == 'ACTIVE' }
  end

  private

  def update_users(okta_users)
    okta_users.each_with_index do |okta_user, _index|
      user = User.find_by('ldap.mail': okta_user.profile.email)
      if user
        attributes_before = user.attributes['okta'].clone
        okta_atts = %i[githubUsername trelloId WorkLocationType siteLocation office employeeStartDate costCenter]
        user['okta'] = okta_user.profile.to_h.slice(*okta_atts)
        if user.changed.present?
          log.info "Okta -> Updating user #{user.username}: " \
                   "#{deep_diff(attributes_before, user.attributes['okta'])}"
        end
        Mongoid::AuditLog.record { user.save! }
      else
        log.debug "Okta -> User not found in db: #{okta_user.profile.email}"
      end
    end
  end

  def cleanup_deactivated_users(okta_users)
    deleted_emails = User.all.map(&:email) - okta_users.map { |u| u.profile.email }
    raise "Too many users to delete (#{deleted_emails.size}), Okta issue?" if deleted_emails.size > 500

    deleted_emails.each do |email|
      log.debug "Dropping deactivated user: #{email}"
      User.find_by('ldap.mail': email).destroy
    end
  end

  def client
    @client ||= Oktakit::Client.new(token: ENV.fetch('okta_token', nil), organization: 'suse')
  end
end
