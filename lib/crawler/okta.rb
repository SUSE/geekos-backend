# Fetching user attributes from Okta

class Crawler::Okta < Crawler::BaseCrawler
  def run
    super

    # https://developer.okta.com/docs/api/resources/users#list-users
    # single user: client.get_user(user.username).first
    okta_users = client.list_users(paginate: true).first.to_a
                       .select { |u| u.status == 'ACTIVE' }.sort_by { |u| u.profile.email }
    log.info "Okta -> Found #{okta_users.size} Okta users"
    okta_users.each_with_index do |okta_user, _index|
      user = User.find_by('ldap.mail': okta_user.profile.email)
      if user
        attributes_before = user.attributes['okta'].clone
        okta_atts = %i[githubUsername trelloId]
        user['okta'] = okta_user.profile.to_h.slice(*okta_atts)
        if user.changed.present?
          log.info "Okta -> Updating user #{user.username}: " \
                   "#{deep_diff(attributes_before, user.attributes['okta'])}"
        end
        Mongoid::AuditLog.record { user.save! }
      else
        log.warn "Okta -> User not found: #{okta_user.profile.email}"
      end
    end
    nil
  end

  def client
    @client ||= Oktakit::Client.new(token: ENV['okta_token'], organization: 'suse')
  end
end
