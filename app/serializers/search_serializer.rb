class SearchSerializer < ActiveModel::Serializer
  attributes :meta
  has_many :results
end
