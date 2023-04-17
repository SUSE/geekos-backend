class OrgUnitSerializer < ActiveModel::Serializer
  attributes :type, :id, :name, :short_description, :description, :parents, :parent, :img,
             :children, :members, :lead

  has_many :members, serializer: UserSummarySerializer

  def type
    'orgunit'
  end

  def img
    object.img&.thumb('160x160#')&.url(host: '')
  end

  # compatibility method, actually there is just one parent
  def parents
    [parent].compact
  end

  def parent
    ParentOrgUnitSerializer.new(object.parent) if object.parent
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
