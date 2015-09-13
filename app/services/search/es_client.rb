module Search
  class EsClient
    def self.client(model = nil)
      model ? model.__elasticsearch__.client : Elasticsearch::Client.new
    end
  end
end
