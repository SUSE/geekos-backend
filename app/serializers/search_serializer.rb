class SearchSerializer < ActiveModel::Serializer
  attributes :meta, :results

  def results
    object.results.map do |result|
      case result.class.name
      when 'User'
        UserSummarySerializer.new(result)
      when 'OrgUnit'
        OrgUnitSerializer.new(result)
      when 'Tag'
        TagSerializer.new(result)
      end
    end
  end
end
