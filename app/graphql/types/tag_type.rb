module Types
  class TagType < Types::BaseObject
    field :description, String, null: true
    field :name, String, null: false
  end
end
