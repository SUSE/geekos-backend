class Tag
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps
  include GraphqlRails::Model

  INDEXED_FIELDS = %i[name description].freeze
  include MongoFtSearchable

  graphql do |c|
    # https://samesystem.github.io/graphql_rails/#/components/model
    # incoming graphql attributes need to be camel case and will get auto transformed to '_'
    c.attribute :name
    c.attribute :description
  end

  field :name, type: String
  field :description, type: String

  validates :name, uniqueness: true, presence: true

  has_and_belongs_to_many :users
end
