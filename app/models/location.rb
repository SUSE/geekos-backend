class Location
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps

  field :abbreviation, type: String
  field :country, type: String
  field :city, type: String
  field :latitude, type: BigDecimal
  field :longitude, type: BigDecimal
  field :address, type: String
  field :floor_id, type: Integer

  validates :abbreviation, presence: true

  has_many :users, dependent: :nullify
end
