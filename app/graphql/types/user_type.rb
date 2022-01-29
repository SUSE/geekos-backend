module Types
  class UserType < Types::BaseObject
    field :admin, Boolean, null: true
    field :birthday, String, null: true
    field :coordinates, String, null: true
    field :country, String, null: true
    field :email, String, null: false
    field :employeenumber, String, null: true
    field :fullname, String, null: true
    field :github_usernames, [String], null: true
    field :join_date, String, null: true
    field :lead_of_org_unit, OrgUnitType, null: true
    field :location, LocationType, null: true
    field :notes, String, null: true
    field :opensuse_username, String, null: true
    field :org_unit, OrgUnitType, null: true
    field :phone, String, null: true
    field :picture, String, null: true do
      argument :size, Integer, required: true
    end
    field :room, String, null: true
    field :tags, [TagType], null: true
    field :title, String, null: true
    field :trello_username, String, null: true
    field :type, String, null: false
    field :username, String, null: false
  end
end
