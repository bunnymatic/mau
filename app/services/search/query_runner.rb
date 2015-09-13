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
      r = EsClient.client.search({ body: {
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
                                     "_all" => {}
                                   }
                                 }
                               }
                             })

      if r.has_key?('hits') && r['hits'].has_key?('hits')
        r['hits']['hits'].map{|hit| OpenStruct.new(hit)}
      end
    end

    def es_client
      es.client
    end
  end
end
