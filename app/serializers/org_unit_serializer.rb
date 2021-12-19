class OrgUnitSerializer < ActiveModel::Serializer
  attributes :id, :name, :short_description, :description, :parents, :img,
             :depth, :depth_name, :children, :members, :lead

  has_many :members, serializer: UserSummarySerializer

  def img
    object.img&.thumb('160x160#')&.url(host: '')
  end

  def parents
    object.parent_ids.map { |o| ParentOrgUnitSerializer.new(OrgUnit.find(o)) }
  end

  def id
    object.id.to_s
  end

  def children
    object.children.sort_by(&:name).map { |o| OrgUnitSummarySerializer.new(o) }
  end

  def lead
    UserSummarySerializer.new(object.lead) if object.lead
  end
end
