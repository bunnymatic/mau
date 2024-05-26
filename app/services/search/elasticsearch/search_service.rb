module Search
  module Elasticsearch
    class SearchService
      def self.index(object)
        object.__elasticsearch__.index_document
      rescue ::Elasticsearch::Transport::Transport::Errors::Forbidden => e
        Rails.logger.error('Failed to index')
        Rails.logger.error(e)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
      end

      def self.reindex(object)
        remove(object)
        index(object)
      rescue ::Elasticsearch::Transport::Transport::Errors::Forbidden => e
        Rails.logger.error('Failed to reindex')
        Rails.logger.error(e)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
      end

      def self.remove(object)
        object.__elasticsearch__.delete_document
      rescue ::Elasticsearch::Transport::Transport::Errors::Forbidden => e
        Rails.logger.error('Failed to remove')
        Rails.logger.error(e)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
      end

      def self.update(object)
        object.__elasticsearch__.update_document
      rescue ::Elasticsearch::Transport::Transport::Errors::Forbidden => e
        Rails.logger.error('Failed to update')
        Rails.logger.error(e)
      rescue ::Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
        index(object)
      end

      def self.reindex_all(clz)
        clz.import(force: true)
      end

      def self.delete_index(clz)
        Search::EsClient.client.indices.delete index: clz.index_name
      end

      def self.create_index(clz)
        Search::EsClient.client.indices.create index: clz.index_name, body: { settings: Search::Indexer::INDEX_SETTINGS }
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
          # highlight: {
          #   fields: {
          #     'studio.name' => {},
          #     'artist.artist_name' => {},
          #     'art_piece.title' => {},
          #     'art_piece.tags' => {},
          #     'art_piece.medium' => {},
          #     'art_piece.title' => {},
          #     'artist.artist_name' => {},
          #   },
          # },
        }

        Search::EsClient.client.search(
          index: %i[art_pieces studios artists].join(','),
          body: query_body,
        )
      end
    end
  end
end
