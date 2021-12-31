class OrgUnitSummarySerializer < ActiveModel::Serializer
  attributes :id, :name, :short_description, :img, :depth, :depth_name, :children

  def img
    object.img&.thumb('160x160#')&.url(host: '')
  end

  def id
    object.id.to_s
  end

  def children
    if @instance_options[:children_depth].nil?
      object.children.sort_by(&:name).map { |o| OrgUnitSummarySerializer.new(o) }
    elsif (@instance_options[:children_depth]).positive?
      object.children.sort_by(&:name).map do |o|
        OrgUnitSummarySerializer.new(o, children_depth: @instance_options[:children_depth] - 1)
      end
    else
      []
    end
  end
end
