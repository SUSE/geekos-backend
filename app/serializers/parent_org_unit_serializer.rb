class ParentOrgUnitSerializer < ActiveModel::Serializer
  attributes :id, :name

  def id
    object.id.to_s
  end
end
