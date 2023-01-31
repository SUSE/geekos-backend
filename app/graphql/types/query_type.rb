module Types
  class QueryType < Types::BaseObject
    # Add `node(id: ID!) and `nodes(ids: [ID!]!)`
    include GraphQL::Types::Relay::HasNodeField
    include GraphQL::Types::Relay::HasNodesField

    field :user, Types::UserType, null: true do
      argument :ident, String, required: true
    end
    field :users, [Types::UserType], null: false
    field :newcomers, [Types::UserType], null: true

    def users
      User.all
    end

    def newcomers
      User.desc('okta.employeeStartDate').limit(25)
    end

    def user(ident:)
      User.find(ident)
    end
  end
end
