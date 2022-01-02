class UserSerializer < UserSummarySerializer
  attributes :employeenumber, :email, :username, :title,
             :fullname, :phone,
             :country, :notes, :gravatar, :picture_160, :picture_25,
             :location, :room, :coordinates,
             :birthday, :teamlead_of, :org_unit, :tags, :admin,
             :opensuse_username, :github_usernames, :trello_username

  def tags
    object.tags.pluck(:name)
  end

  def org_unit
    OrgUnitSummarySerializer.new(object.org_unit, children_depth: 0) if object.org_unit
  end

  def admin
    !!object.admin
  end
end
