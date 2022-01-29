class Tag
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps

  INDEXED_FIELDS = %i[name description].freeze
  include MongoFtSearchable

  field :name, type: String
  field :description, type: String

  validates :name, uniqueness: true, presence: true

  has_and_belongs_to_many :users
end
