class EsSearchService
  def initialize(model, query = nil)
    @query = query
    @model = model
  end

  def search
    t = Time.now.to_f
    result = if @query.present?
               @model.search(@query).response.try(:hits).try(:hits)
             else
               []
             end
    puts "Query #{@query} %4.4fms" % (Time.now.to_f - t)
    result
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
