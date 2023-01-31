module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, Types::UserType, null: true do
      argument :ident, String, required: true
    end
    field :users, [Types::UserType], null: false do
      argument :limit, Integer, required: false
      argument :order, String, required: false
    end

    def users(order: nil, limit: nil)
      users = User.all
      users = users.sort({order: -1}) if order
      users = users.limit(limit) if limit
      users
    end

    def user(ident:)
      User.find(ident)
    end
  end
end
