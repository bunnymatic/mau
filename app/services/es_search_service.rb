class EsSearchService
  def initialize(model, query = nil)
    @query = query
    @model = model
  end

  def search
    t = Time.now.to_f
    return [] unless @query.present?
    results = if @model
                single_index_search
              else
                multi_index_search
              end
    begin
      puts "Query #{@query} %4.4fms" % (Time.now.to_f - t)
    rescue
    end
    results
  end

  def single_index_search
    @model.search({
      body: {
        size: 100,
        query: {
          match: {
            "_all" => @query
          }
        },
        highlight: {
          pre_tags: ['<span class="search-highlight">'],
          post_tags: ['</span>'],
          fields: {
            "_all" => {}
          }
        }
      }
    }).response.try(:hits).try(:hits)
  end

  def multi_index_search
    base_client = Elasticsearch::Client.new
    r = base_client.search({ body: {
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

  def reindex
    begin
      es_client.indices.delete index: @model.index_name
    rescue Elasticsearch::Transport::Transport::Errors::NotFound
    end
    es.create_index! force: true
    index
  end

  def index
    puts "creating #{@model.index_name} search index"
    @model.import
  end

  def es
    @model.__elasticsearch__
  end

  def es_client
    es.client
  end
end
