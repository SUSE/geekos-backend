class OrgUnit
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::Tree
  include Mongoid::Tree::Traversal
  extend Dragonfly::Model

  DEPTH_NAMES = {
    0 => { lead: 'CEO', unit: 'Company' },
    1 => { lead: 'President', unit: 'Organization' },
    2 => { lead: 'Vice President', unit: 'Group' },
    3 => { lead: 'Department lead', unit: 'Department' },
    4 => { lead: 'Teamlead', unit: 'Team' }
  }.freeze

  INDEXED_FIELDS = %i[name short_description description].freeze
  include MongoFtSearchable

  field :name, type: String
  field :short_description, type: String
  field :description, type: String

  field :type, type: String

  # http://markevans.github.io/dragonfly/
  dragonfly_accessor :img
  field :img_uid, type: String

  has_one :lead, class_name: 'User', dependent: :nullify, inverse_of: :lead_of_org_unit
  has_many :members, class_name: 'User', dependent: :nullify, inverse_of: :org_unit

  scope :org_groups, -> { where(type: 'Group') }
  scope :departments, -> { where(type: 'Department') }
  scope :teams, -> { where(type: 'Team') }

  def self.types
    DEPTH_NAMES.values
  end

  def depth_name
    DEPTH_NAMES[depth]
  end

  # :nocov:
  def self.print
    traverse(:depth_first) do |node|
      indentation = '  ' * node.depth
      puts "#{indentation}#{node.name}" # rubocop:disable Rails/Output
    end
  end
  # :nocov:
end
