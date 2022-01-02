require 'active_support/concern'

# We need `read_attribute` here to make eg. 'ldap.title' work
# rubocop:disable Rails/ReadWriteAttribute

module MongoAttrMapping
  extend ActiveSupport::Concern

  class_methods do
    def attribute_mapping(name, target, overwriteable: false)
      define_method name do
        self[name] || read_attribute(target)
      end
      return unless overwriteable

      define_method "#{name}=" do |value|
        # reset value if it's the same as the shadowed field
        value = nil if value == read_attribute(target)
        self[name] = value
      end
      field(name, type: String)
    end
  end
end

# rubocop:enable Rails/ReadWriteAttribute
