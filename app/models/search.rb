class Search
  include ActiveModel::Model

  attr_reader :results, :meta

  def initialize(query, klasses)
    @klasses = [klasses].flatten
    @query = query
    @results = []
    @meta = { hits: 0, took: 0 }
    perform!
  end

  def perform!
    @meta[:took] = Benchmark.ms do
      @klasses.each do |klass|
        klass.match(@query).each do |record|
          @results << record
        end
      end
    end
    @meta[:hits] = @results.count
  end

  alias read_attribute_for_serialization send
end
