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
    puts "Query #{@query} %4.4fms", Time.now.to_f - t
    result
  end

  def index_settings
    {
      analysis: {
        analyzer: {
          mau_analyzer: {
            filter: ['standard', 'lowercase', 'snowball']
          },
          tokenizer: {
            standard_tokenizer: {}
          }
        }
      }
    }
  end

  def index_mappings
    {
      artist: {
        _all: {
          analyzer: 'mau__analyzer'
        },
        properties: {
          name: {
            type: 'string',
            analyzer: 'mau__analyzer'
          },
          title: {
            type: 'string',
            analyzer: 'mau__analyzer'
          },
          first_name: {
            type: 'string',
            analyzer: 'mau__analyzer'
          },
          last_name: {
            type: 'string',
            analyzer: 'mau__analyzer'
          }
          # tags: {
          #   type: 'nested',
          #   properties: {
          #       key: { type: 'string', index: 'not_analyzed' },
          #       value: { type: 'string', index: 'not_analyzed' }
          #     }
          #   },
          #   taxonomies: {
          #     type: 'nested',
          #     include_in_parent: true,
          #     properties: {
          #       key: { type: 'string', index: 'not_analyzed' },
          #       value: { type: 'string', index: 'not_analyzed' },
          #       branch: { type: 'string', index: 'not_analyzed' }
          #     }
          #   }
          # }
        }
      }
    }
  end
  
  
  def index
    puts "creating #{@model.index_name} search index"
    @model.__elasticsearch__.client.indices.delete index: @model.index_name rescue nil
    @model.__elasticsearch__.client.indices.create index: @model.index_name, body: { settings: index_settings, mappings: index_mappings }
    @model.import
  end
end
