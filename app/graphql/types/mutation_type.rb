module Types
  class MutationType < Types::BaseObject
    field :updateUser, mutation: Mutations::UpdateUser, description: "Update a user"
  end
end
