module Search
  class Indexer
    INDEX_SETTINGS = {
      max_ngram_diff: 4,
      number_of_shards: 1,
      number_of_replicas: 0,
      blocks: {
        read_only_allow_delete: 'false',
      },
    }.freeze

    ANALYZERS = {
      mau_ngram_analyzer: {
        tokenizer: :mau_ngram_tokenizer,
        filter: ['lowercase'],
      },
    }.freeze
    TOKENIZERS = {
      mau_ngram_tokenizer: {
        type: FeatureFlags.use_open_search? ? 'ngram' : 'nGram',
        min_gram: 3,
        max_gram: 6,
        token_chars: %i[letter digit],
      },
    }.freeze

    ANALYZERS_TOKENIZERS = {
      analyzer: ANALYZERS,
      tokenizer: TOKENIZERS,
    }.freeze

    MULTI_MATCH_QUERY_FIELDS = [
      'art_piece.title^10',
      'studio.name^5',
      'artist.artist_name^5',
      'art_piece.title_ngram^3',
      'art_piece.artist_name^3',
      'artist.firstname',
      'artist.lastname',
      'art_piece.medium',
      'art_piece.tags',
    ].freeze

    KNOWN_SEARCH_INDICES = [Artist, Studio, ArtPiece].map { |clz| clz.name.underscore.downcase.pluralize }.freeze

    class ArtPieceSearchService
      # this class helps keep track updating artist information in the search index
      # when we update art piece information
      def self.index(object)
        ::Search::SearchService.index(object)
        ::Search::SearchService.index(object.artist)
      end

      def self.reindex(object)
        ::Search::SearchService.reindex(object)
        ::Search::SearchService.reindex(object.artist)
      end

      def self.update(object)
        ::Search::SearchService.update(object)
        ::Search::SearchService.update(object.artist)
      end

      def self.remove(object)
        ::Search::SearchService.remove(object)
      end
    end

    class ArtistSearchService
      # this class helps keep track updating art_piece information in the search index
      # when we update the artist
      def self.index(object)
        return unless object.active?

        ::Search::SearchService.index(object)
        object.art_pieces.each do |art|
          ::Search::SearchService.index(art)
        end
      end

      def self.reindex(object)
        return unless object.active?

        ::Search::SearchService.reindex(object)
        object.art_pieces.each do |art|
          ::Search::SearchService.reindex(art)
        end
      end

      def self.update(object)
        return unless object.active?

        ::Search::SearchService.update(object)
        object.art_pieces.each do |art|
          ::Search::SearchService.update(art)
        end
      end

      def self.remove(object)
        ::Search::SearchService.remove(object)
        object.art_pieces.each do |art|
          ::Search::SearchService.remove(art)
        end
      end
    end

    class StudioSearchService < ::Search::SearchService
    end

    def self.run_es_method_on_object(method, object)
      case object.class.name
      when Studio.name
        StudioSearchService.public_send(method, object)
      when Artist.name
        ArtistSearchService.public_send(method, object)
      when ArtPiece.name
        ArtPieceSearchService.public_send(method, object)
      end
    end

    def self.reindex_all(clz)
      ::Search::SearchService.reindex_all(clz)
    end

    def self.create_index(clz)
      ::Search::SearchService.create_index(clz)
    end

    def self.delete_index(clz)
      ::Search::SearchService.delete_index(clz)
    end

    def self.index(object)
      run_es_method_on_object(:index, object)
    end

    def self.reindex(object)
      run_es_method_on_object(:reindex, object)
    end

    def self.remove(object)
      run_es_method_on_object(:remove, object)
    end

    def self.update(object)
      run_es_method_on_object(:update, object)
    end
  end
end
