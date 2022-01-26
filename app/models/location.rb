class Location
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps

  include GraphqlRails::Model

  graphql do |c|
    # https://samesystem.github.io/graphql_rails/#/components/model
    # incoming graphql attributes need to be camel case and will get auto transformed to '_'
    c.attribute :_id
    c.attribute :abbreviation
    c.attribute :address
    c.attribute :country
  end

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
