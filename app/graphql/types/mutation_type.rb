module Types
  class MutationType < Types::BaseObject
    field :user, mutation: Mutations::UpdateUser, description: "Update a user"
  end
end
