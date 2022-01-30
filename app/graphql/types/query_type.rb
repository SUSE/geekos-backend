module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, Types::UserType, null: false do
      argument :ident, String, required: true
    end
    field :users, [Types::UserType], null: false

    def users
      User.all
    end

    def user(ident:)
      User.find(ident)
    end
  end
end
