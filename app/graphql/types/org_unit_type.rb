module Types
  class OrgUnitType < Types::BaseObject
    field :id, ID, null: false
    field :name, String, null: true
    field :type, String, null: false
  end
end
