class TagSerializer < ActiveModel::Serializer
  attributes :name, :description, :users, :created_at, :updated_at

  def users
    object.users.map { |u| UserSummarySerializer.new(u) }
  end
end
