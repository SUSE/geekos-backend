module Types
  class LocationType < Types::BaseObject
    field :abbreviation, String, null: true
    field :address, String, null: true
    field :city, String, null: true
    field :country, String, null: true
    field :id, ID, null: false
    field :latitude, String, null: true
    field :longitude, String, null: true
  end
end
