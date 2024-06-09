module Search
  class SearchService
    # API layer to switch between underlying search implementations
    def self.service
      FeatureFlags.use_open_search? ? Search::OpenSearch::SearchService : Search::Elasticsearch::SearchService
    end

    class << self
      delegate :index, :update, :reindex, :remove, :reindex_all, :create_index, :delete_index, :multi_index_search, :search, to: :service
    end
  end
end
