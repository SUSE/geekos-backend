class ParentOrgUnitSerializer < ActiveModel::Serializer
  attributes :id, :name, :depth_name

  def id
    object.id.to_s
  end
end
