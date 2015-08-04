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
    puts "Query #{@query} %4.4fms" % (Time.now.to_f - t)
    results
  end

  def single_index_search
    @model.search({body: { size: 30, query: { match: { "_all" => @query } } } }).response.try(:hits).try(:hits)
  end

  def multi_index_search
    base_client = Elasticsearch::Client.new
    r = base_client.search q: @query, size: 25
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
