class TagSerializer < ActiveModel::Serializer
  attributes :type, :name, :description, :users, :created_at, :updated_at

  def type
    'tag'
  end

  def users
    object.users.map { |u| UserSummarySerializer.new(u) }
  end
end
