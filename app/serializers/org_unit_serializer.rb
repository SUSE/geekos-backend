class OrgUnitSerializer < ActiveModel::Serializer
  attributes :type, :id, :name, :short_description, :description, :parents, :img,
             :children, :members, :lead

  has_many :members, serializer: UserSummarySerializer

  def type
    'orgunit'
  end

  def img
    object.img&.thumb('160x160#')&.url(host: '')
  end

  # all parent org units up to the top
  def parents
    object.parent_ids.filter_map { |id| OrgUnit.find(id) }.map { |o| ParentOrgUnitSerializer.new(o) }
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
