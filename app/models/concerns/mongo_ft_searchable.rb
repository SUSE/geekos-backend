require 'active_support/concern'

module MongoFtSearchable
  extend ActiveSupport::Concern

  included do
    # https://docs.mongodb.com/manual/core/index-text/
    # there can only be one text index per class, which includes all fields
    indexes = self::INDEXED_FIELDS.index_with { |_field| 'text' }
    index(indexes, { name: "ft_#{name.underscore}" })
  end
  class_methods do
    def match(query)
      where({ :$text => { :$search => "\"#{query}\"" } })
    end
  end
end
