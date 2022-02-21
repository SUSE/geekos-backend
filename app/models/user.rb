class User
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps
  include Mongoid::AuditLog
  include MongoAttrMapping
  extend Dragonfly::Model

  INDEXED_FIELDS = [:title, :notes, :opensuse_username, 'ldap.title', 'ldap.mail',
                    'ldap.samaccountname', 'ldap.displayname', 'okta.githubUsername',
                    'okta.trelloId'].freeze
  include MongoFtSearchable

  after_initialize :reset_auth_token, if: :new_record?

  belongs_to :manager, class_name: 'User', inverse_of: :subordinates, optional: true
  has_many :subordinates, class_name: 'User', inverse_of: :manager
  belongs_to :location, optional: true
  has_and_belongs_to_many :tags
  belongs_to :org_unit, optional: true, inverse_of: :members
  belongs_to :lead_of_org_unit, class_name: 'OrgUnit', optional: true, inverse_of: :lead

  # user attributes:
  field :room, type: String
  field :coordinates, type: String
  field :notes, type: String
  field :birthday, type: String
  field :opensuse_username, type: String

  # internal
  field :auth_token, type: String
  field :admin, type: Boolean
  dragonfly_accessor :img # http://markevans.github.io/dragonfly/
  field :img_uid, type: String
  alias history audit_log_entries

  # Synced attributes
  field :ldap, type: Hash, default: {}
  field :okta, type: Hash, default: {}

  # Mappings:
  attribute_mapping :title, 'ldap.title', overwriteable: true
  attribute_mapping :phone, 'ldap.telephonenumber', overwriteable: true
  attribute_mapping :email, 'ldap.mail'
  attribute_mapping :username, 'ldap.samaccountname'
  attribute_mapping :fullname, 'ldap.displayname'
  attribute_mapping :country, 'ldap.co'
  attribute_mapping :employeenumber, 'ldap.employeenumber'
  attribute_mapping :github_usernames, 'okta.githubUsername'
  attribute_mapping :trello_username, 'okta.trelloId'
  attribute_mapping :join_date, 'okta.employeeStartDate'

  validates :auth_token, uniqueness: true, presence: true
  validates :coordinates, format: { with: /\A-?\d{1,2}\.\d{1,15}, ?-?\d{1,3}\.\d{1,15}\z/,
                                    message: "requires format like '49.446444, 11.330570'" }, allow_blank: true

  def self.find(ident)
    query = ident.numeric? ? { 'ldap.employeenumber': ident } : { 'ldap.samaccountname': ident }
    find_by(query) || find_by(id: ident)
  end

  def gravatar
    "https://gravatar.com/avatar/#{email_hexdigest}?d=retro" if email_hexdigest
  end

  def email_hexdigest
    Digest::MD5.hexdigest(email.downcase) if email.present?
  end

  def reset_auth_token
    self.auth_token = SecureRandom.hex unless auth_token
  end

  def picture(size: 50)
    img&.thumb("#{size}x#{size}#")&.url(host: '')
  end
end
