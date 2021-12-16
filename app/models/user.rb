class User
  include ActiveModel::Model
  include Mongoid::Document
  include Mongoid::Timestamps
  extend Dragonfly::Model

  INDEXED_FIELDS = [:title, :notes, :accounts, 'ldap.title', 'ldap.mail',
                    'ldap.samaccountname', 'ldap.displayname'].freeze
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
  # account usernames: github, trello, opensuse, ucs
  field :accounts, type: Hash, default: {}

  # internal
  field :auth_token, type: String
  field :admin, type: Boolean
  # http://markevans.github.io/dragonfly/
  dragonfly_accessor :img
  field :img_uid, type: String

  # ldap fields:
  # (cn c st title physicaldeliveryofficename displayName co company streetaddress
  #  employeenumber employeetype samaccountname mail manager employeestatus sitelocation
  #  employeestartdate telephoneNumber manager_employeenumber)
  field :ldap, type: Hash, default: {}

  validates :auth_token, uniqueness: true, presence: true
  validates :coordinates, format: { with: /-?\d{1,2}\.\d{1,14}, ?-?\d{1,3}\.\d{1,14}/,
                                    message: "requires format like '49.446444, 11.330570'" }, allow_blank: true

  ldap_attributes = { title: :title,
                      email: :mail,
                      username: :samaccountname,
                      fullname: :displayname,
                      phone: :telephonenumber,
                      country: :co,
                      employeenumber: :employeenumber }

  # mapping to ldap fields with option to overwrite LDAP_OVERWRITEABLE_FIELDS in User
  LDAP_OVERWRITEABLE_FIELDS = %i[title telephonenumber].freeze
  ldap_attributes.each do |mapping|
    define_method mapping.first do
      LDAP_OVERWRITEABLE_FIELDS.include?(mapping.last) ? self[mapping.first] || ldap[mapping.last] : ldap[mapping.last]
    end
    field(mapping.first, type: String) if LDAP_OVERWRITEABLE_FIELDS.include?(mapping.last)
  end

  def self.find(ident)
    query = ident.numeric? ? { 'ldap.employeenumber': ident } : { 'ldap.samaccountname': ident }
    User.find_by(query)
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
end
