class UserSummarySerializer < ActiveModel::Serializer
  attributes :email, :username, :title, :fullname, :phone, :gravatar, :picture_160,
             :picture_25, :email, :teamlead_of

  def picture_160
    object.img&.thumb('160x160#')&.url(host: '')
  end

  def picture_25
    object.img&.thumb('25x25#')&.url(host: '')
  end

  def teamlead_of
    OrgUnitSummarySerializer.new(object.lead_of_org_unit, children_depth: 0) if object.lead_of_org_unit
  end
end
