class UserSearchSerializer < ActiveModel::Serializer
  attributes :meta
  has_many :results, serializer: UserSummarySerializer
end
