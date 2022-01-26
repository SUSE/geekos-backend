class OrgUnit
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Traversal
  include Mongoid::AuditLog
  extend Dragonfly::Model

  INDEXED_FIELDS = %i[name short_description description].freeze
  include MongoFtSearchable

  include GraphqlRails::Model

  graphql do |c|
    # https://samesystem.github.io/graphql_rails/#/components/model
    # incoming graphql attributes need to be camel case and will get auto transformed to '_'
    c.attribute :type
    c.attribute :id
    c.attribute :name
  end

  field :name, type: String
  field :short_description, type: String
  field :description, type: String

  # http://markevans.github.io/dragonfly/
  dragonfly_accessor :img
  field :img_uid, type: String

  has_one :lead, class_name: 'User', dependent: :nullify, inverse_of: :lead_of_org_unit
  has_many :members, class_name: 'User', dependent: :nullify, inverse_of: :org_unit

  def type
    self.class.name.downcase
  end

  # :nocov:
  def self.print
    traverse(:depth_first) do |node|
      indentation = '  ' * node.depth
      puts "#{indentation}#{node.name}" # rubocop:disable Rails/Output
    end
    nil
  end
  # :nocov:
end
