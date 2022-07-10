namespace :migrate do
  desc 'migrate to Okta attributes'
  task okta_attributes: :environment do
    User.all.each do |user|
      user.update(okta: {})
      user.update(opensuse_username: user.read_attribute('accounts')['opensuse'])
      user.okta['trelloId'] = user.read_attribute('accounts')['trello']
      if user.read_attribute('accounts')['github']
        user.okta['githubUsername'] =
          [user.read_attribute('accounts')['github']]
      end
      user.write_attribute('accounts', nil)
      user.update(title: nil) if user.ldap['title'] == user.read_attribute('title')
      user.update(phone: nil) if user.ldap['telephonenumber'] == user.read_attribute('phone')
      user.save!
    end
  end

  desc 'migrate from local_user to new user model'
  task off_local_users: :environment do
    LocalUser.each do |luser|
      user = User.find(luser.workforceid)
      if user
        Rails.logger.info "Migrating user #{user.username}"
        luser.coordinates = nil if luser.coordinates == 'null'
        user.update!(
          title: luser.title,
          tag_ids: luser.tag_ids,
          room: luser.room,
          phone: luser.phone,
          notes: luser.notes,
          location_id: luser.location_id,
          img_uid: luser.img_uid,
          coordinates: luser.coordinates,
          auth_token: luser.auth_token,
          admin: luser.admin
        )
        luser.external_tools.each do |account|
          user.accounts[account.tool_type.downcase] = account.tool_alias
        end
        user.save!
        user.lead_of_org_unit&.update!(name: luser.team_name, short_description: luser.team_short_description,
                                       description: luser.team_description)
      else
        Rails.logger.info "User not found: #{LdapUser.find_by(workforceid: luser.workforceid).try(:fullname)} " \
                          "(#{luser.workforceid})"
      end
    end
  end
end
