require 'active_support/concern'

module MongoAttrMapping
  extend ActiveSupport::Concern

  class_methods do
    def attribute_mapping(name, target, overwriteable: false)
      define_method name do
        # We need `read_attribute` here to make eg. 'ldap.title' work
        # rubocop:disable Rails/ReadWriteAttribute
        self[name] || read_attribute(target)
        # rubocop:enable Rails/ReadWriteAttribute
      end
      field(name, type: String) if overwriteable
    end
  end
end
