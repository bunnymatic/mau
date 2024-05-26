module Search
  module OpenSearch
    class SearchService
      def self.index(object)
        searchable = Search::SearchableObject.new(object)
        return if searchable.document.blank?

        Search::OpenSearchClient.index(
          searchable.index_name,
          searchable.id,
          searchable.document,
        )
      end

      def self.reindex(object)
        remove(object)
        index(object)
      end

      def self.remove(object)
        searchable = Search::SearchableObject.new(object)

        Search::OpenSearchClient.delete(
          searchable.index_name,
          searchable.id,
        )
      end

      def self.update(object)
        searchable = Search::SearchableObject.new(object)
        return if searchable.document.blank?

        Search::OpenSearchClient.update(
          searchable.index_name,
          searchable.id,
          searchable.document,
        )
      end

      def self.reindex_all(clz)
        clz.all.map { |obj| reindex(obj) }
      end

      def self.delete_index(clz)
        index = Search::SearchableObject.index_by_object_type(clz)
        Search::OpenSearchClient.delete_index(index)
      end

      def self.create_index(clz)
        index = Search::SearchableObject.index_by_object_type(clz)
        Search::OpenSearchClient.create_index(index,
                                              settings: Search::Indexer::INDEX_SETTINGS,
                                              analysis: Search::Indexer::ANALYZERS_TOKENIZERS,
                                              mappings: Search::SearchableObject.mappings_by_object_type(clz))
      end

      def self.search(query)
        query_body = {
          query: {
            multi_match: {
              query:,
              fields: Search::Indexer::MULTI_MATCH_QUERY_FIELDS,
              type: 'most_fields',
              fuzziness: 0,
            },
          },
          size: 100,
        }
        Search::OpenSearchClient.multi_index_search(
          Search::SearchableObject.all_searchable_indices,
          query_body,
        )
      end
    end
  end
end
