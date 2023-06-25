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
        type: 'nGram',
        min_gram: 3,
        max_gram: 6,
        token_chars: %i[letter digit],
      },
    }.freeze

    ANALYZERS_TOKENIZERS = {
      analyzer: ANALYZERS,
      tokenizer: TOKENIZERS,
    }.freeze

    class ObjectSearchService
      attr_reader :object

      def initialize(object)
        @object = object
      end

      def index
        object.__elasticsearch__.index_document
      rescue Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
      end

      def reindex
        remove
        index
      rescue Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
      end

      def remove
        object.__elasticsearch__.delete_document
      rescue Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
      end

      def update
        object.__elasticsearch__.update_document
      rescue Elasticsearch::Transport::Transport::Errors::NotFound, Faraday::ConnectionFailed
        index
      end
    end

    class ArtPieceSearchService < ObjectSearchService
      def index
        super
        ObjectSearchService.new(object.artist).index
      end

      def reindex
        super
        ObjectSearchService.new(object.artist).reindex
      end

      def update
        super
        ObjectSearchService.new(object.artist).update
      end
    end

    class ArtistSearchService < ObjectSearchService
      def index
        return unless object.active?

        super
        object.art_pieces.each do |art|
          ObjectSearchService.new(art).index
        end
      end

      def reindex
        return unless object.active?

        super
        object.art_pieces.each do |art|
          ObjectSearchService.new(art).reindex
        end
      end

      def update
        return unless object.active?

        super
        object.art_pieces.each do |art|
          ObjectSearchService.new(art).update
        end
      end

      def remove
        super
        object.art_pieces.each do |art|
          ObjectSearchService.new(art).remove
        end
      end
    end

    class StudioSearchService < ObjectSearchService
    end

    WAIT_FOR_ACTIVE_STORAGE_SECONDS = 5

    def self.import(clz, opts = nil)
      clz.import opts
    end

    def self.reindex_all(clz)
      import(clz, force: true)
    end

    def self.index(object, async: true)
      job = get_job_class(object)
      return unless job

      async ? job.set(wait_until: WAIT_FOR_ACTIVE_STORAGE_SECONDS.seconds.since).perform_later(object.id, :index) : job.perform_now(object.id, :index)
    end

    def self.reindex(object, async: true)
      job = get_job_class(object)
      return unless job

      if async
        job.set(wait_until: WAIT_FOR_ACTIVE_STORAGE_SECONDS.seconds.since).perform_later(object.id,
                                                                                         :reindex)
      else
        job.perform_now(object.id, :reindex)
      end
    end

    def self.update(object, async: true)
      job = get_job_class(object)
      return unless job

      if async
        job.set(wait_until: WAIT_FOR_ACTIVE_STORAGE_SECONDS.seconds.since).perform_later(object.id,
                                                                                         :update)
      else
        job.perform_now(object.id, :update)
      end
    end

    def self.remove(object, async: true)
      job = get_job_class(object)
      return unless job

      if async
        job.set(wait_until: WAIT_FOR_ACTIVE_STORAGE_SECONDS.seconds.since).perform_later(object.id,
                                                                                         :remove)
      else
        job.perform_now(object.id, :remove)
      end
    end

    class << self
      private

      def get_job_class(object)
        object_type = object.class.name
        job_class = "Search::Jobs::#{object_type}"
        job_class.constantize
      rescue NameError
        nil
      end
    end
  end
end
