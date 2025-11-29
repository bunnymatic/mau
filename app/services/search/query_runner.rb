module Search
  class SearchHit
    include ActiveModel::Model

    attr_accessor :_index, :_type, :_id, :_score, :_source, :_ignored

    def ==(other)
      self.class == other.class &&
        _id == other._id &&
        _index == other._index &&
        _score == other._score &&
        _source == other._source
    end

    def as_json
      { _type:, _id:, _score:, _source: }.as_json
    end
  end

  class QueryRunner
    def initialize(query = nil)
      @query = query
    end

    def search
      return [] if @query.blank?

      results = Search::SearchService.search(@query)
      package_results(results)
    end

    private

    def package_results(raw_results)
      return unless raw_results.key?('hits') && raw_results['hits'].key?('hits')

      raw_results['hits']['hits'].map do |hit|
        highlights = hit['highlight'] || {}
        highlights.each do |full_field, value|
          field1, field2 = full_field.split('.')
          hit['_source'][field1][field2] = value if [field1, field2, value].all?(&:present?)
        end
        SearchHit.new(hit)
      end
    end
  end
end
