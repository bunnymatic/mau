module Search
  class QueryRunner
    def initialize(query = nil)
      @query = query
    end

    def search
      t = Time.now.to_f
      return [] unless @query.present?
      results = multi_index_search
      begin
        puts "Query #{@query} %4.4fms" % (Time.now.to_f - t)
      rescue
      end
      results
    end

    def multi_index_search
      r = EsClient.client.search(
        {
          body: {
            query: {
              match: {
                '_all' => @query
              }
            },
            size: 100,
            highlight: {
              pre_tags: ['<span class="search-highlight">'],
              post_tags: ['</span>'],
              fields: {
                "*" => {},
              }
            }
          }
        })

      if r.has_key?('hits') && r['hits'].has_key?('hits')
        r['hits']['hits'].map do |hit|
          highlights = hit['highlight'] || {}
          highlights.each do |full_field, value|
            field1, field2 = full_field.split(".")
            hit["_source"][field1][field2] = value if [field1,field2,value].all?(&:present?)
          end
          OpenStruct.new(hit)
        end
      end
    end

    def es_client
      es.client
    end
  end
end
