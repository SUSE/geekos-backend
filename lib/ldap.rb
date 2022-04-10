require 'net-ldap'

# https://rubydoc.info/gems/ruby-net-ldap/Net/LDAP
## Ldap Queries
# * Finding a user: `Ldap.search_by_uid('tschmidt')`
### Using ldapsearch
#
# * without bind: `ldapsearch -x -H ldaps://ldap.server -b "OU=User accounts,DC=corp,DC=suse,DC=com" \
#                  "SAMAccountName=tom"`
# * with bind: `ldapsearch -x -H ldaps://ldap.server -b "OU=User accounts,DC=corp,DC=suse,DC=com" "SAMAccountName=tom" \
#               -D CN=x read,OU=Accounts,OU=Account Operators,OU=Admin,DC=corp,DC=suse,DC=com" -W`

class Ldap
  class Configuration
    attr_accessor :host, :port, :method, :base, :login, :password, :desired_attr

    def initialize
      @host     = ENV['geekos_ldap_host']
      @port     = ENV['geekos_ldap_port']
      @method   = (ENV['geekos_ldap_port'] == '389' ? nil : :simple_tls)
      @base     = ENV['geekos_ldap_base']
      @login    = ENV['geekos_ldap_login']
      @password = ENV['geekos_ldap_password']

      @desired_attr = %w[
        title
        displayName
        cn
        co
        employeenumber
        samaccountname
        mail
        manager
        telephoneNumber
      ]
    end
  end

  class Connection
    attr_accessor :ldap

    def initialize
      configuration = Ldap.configuration

      # https://github.com/ruby-ldap/ruby-net-ldap/blob/master/lib/net/ldap.rb#L546
      @ldap = Net::LDAP.new host: configuration.host,
                            port: configuration.port,
                            base: configuration.base,
                            encryption: configuration.method
      @ldap.authenticate(configuration.login, configuration.password) if configuration.login.present?
      raise SystemCallError, "Unable to bind to ldap server: #{@ldap.get_operation_result.message}" unless @ldap.bind
    end
  end

  class << self
    def all_users
      result = Rails.cache.fetch('all_ldap_users', expires_in: 1.hour) do
        filter = Net::LDAP::Filter.construct('SAMAccountName=*')
        rehash(Ldap.connection.ldap.search(filter:, return_result: true, attributes: configuration.desired_attr))
      end
      result.values
    end

    def active_users
      result = Rails.cache.fetch('all_suse_ldap_users', expires_in: 1.hour) do
        # EMPLOYEESTATUS values: ["Terminated", "Active", "", "On Leave", "Pending", "Retired"]
        filter = Net::LDAP::Filter.construct('(| (EMPLOYEESTATUS=Active) (EMPLOYEESTATUS=On Leave))')
        rehash(Ldap.connection.ldap.search(filter:, return_result: true, attributes: configuration.desired_attr))
      end
      result.values
    end

    def connection
      @connection ||= Connection.new
    end

    def configuration
      @configuration ||= Configuration.new
    end

    def configure
      yield configuration
    end

    def search(search_param)
      search_param = "*#{search_param}*"
      all_filters = configuration.desired_attr.map do |attr|
        Net::LDAP::Filter.eq(attr, search_param)
      end
      filter = Net::LDAP::Filter.construct("(|#{all_filters.join})")
      result = Ldap.connection.ldap.search(filter:, attributes: configuration.desired_attr, return_result: true)
      rehash(result)
    end

    def search_by_uid(uid)
      filter = Net::LDAP::Filter.eq('SAMAccountName', uid)
      result = Ldap.connection.ldap.search(filter:, return_result: true)
      rehash(result)
    end

    def search_by_cn(uid)
      filter = Net::LDAP::Filter.eq('cn', uid)
      result = Ldap.connection.ldap.search(filter:, return_result: true)
      rehash(result)
    end

    private

    # returns a Hash like {'mdidonato' => {"cn"=>"Melissa Di Donato", ...}}
    def rehash(search_result)
      result = {}
      search_result.each do |row|
        user = {}
        row.attribute_names.each do |attr|
          user[attr.to_s] = begin
            row.send(attr).first.force_encoding('utf-8')
          rescue StandardError
            ''
          end
        end
        result[row.SAMAccountName.first] = user
      end
      result
    end
  end
end
