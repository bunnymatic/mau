module Search
  class QueryRunner
    def initialize(query = nil, include_highlight = true)
      @query = query
    end

    def search
      t = Time.now.to_f
      return [] unless @query.present?
      results = multi_index_search
      package_results(results)
    end

    def multi_index_search
      EsClient.client.search(
        {
          index: [:art_pieces, :studios, :artists].join(","),
          body: {
            query: {
              match: {
                '_all' => @query
              }
            },
            size: 100,
            highlight: {
              fields: {
                "name" => {},
                "tags" => {},
                "title" => {},
                "artist_name" => {},
                "artist_bio" => {},
                "bio" => {}
              }
            }
          }
        })
    end

    def package_results(raw_results)
      return unless raw_results.has_key?('hits') && raw_results['hits'].has_key?('hits')

      raw_results['hits']['hits'].map do |hit|
        highlights = hit['highlight'] || {}
        highlights.each do |full_field, value|
          field1, field2 = full_field.split(".")
          hit["_source"][field1][field2] = value if [field1,field2,value].all?(&:present?)
        end
        OpenStruct.new(hit)
      end
    end

    def es_client
      es.client
    end
  end
end
