module Search
  class EsClient
    def self.root_es_client
      ::Elasticsearch::Client.new(url: Rails.application.config.elasticsearch_url)
    end

    def self.client(model = nil)
      model ? model.__elasticsearch__.client : root_es_client
    end
  end
end
