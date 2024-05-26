module Search
  class SearchableObject
    class NotSearchableObject < StandardError; end

    MAPPINGS_BY_OBJECT = {
      artist: {
        artist_name: { type: 'text', analyzer: :mau_ngram_analyzer },
        firstname: { type: 'text', analyzer: :mau_ngram_analyzer },
        lastname: { type: 'text', analyzer: :mau_ngram_analyzer },
        nomdeplume: { type: 'text', analyzer: :mau_ngram_analyzer },
        studio_name: { type: 'text', analyzer: :mau_ngram_analyzer },
        bio: { type: 'text', index: false },
      },
      art_piece: {
        title: { type: 'text', analyzer: 'english' },
        title_ngram: { type: 'text', analyzer: :mau_ngram_analyzer },
        year: { type: 'text' },
        medium: { type: 'text', analyzer: 'english' },
        artist_name: { type: 'text', analyzer: :mau_ngram_analyzer },
        studio_name: { type: 'text', analyzer: :mau_ngram_analyzer },
        tags: { type: 'text', analyzer: 'english' },
      },
      studio: {
        name: { type: 'text', analyzer: :mau_ngram_analyzer },
        address: { type: 'text', analyzer: :mau_ngram_analyzer },
      },
    }.freeze

    attr_reader :object

    delegate :id, to: :object

    def initialize(object)
      @object = object
    end

    def index_name
      SearchableObject.index_by_object_type(object.class)
    end

    def document_type
      object.class.name.underscore
    end

    def document
      raise NotSearchableObject, 'the object must implement `as_indexed_json` to be searchable' unless object.respond_to?(:as_indexed_json)

      object.as_indexed_json
    end

    def self.all_searchable_indices
      %w[art_pieces artists studios].freeze
    end

    def self.index_by_object_type(clz)
      index = clz.name.underscore.pluralize
      unless all_searchable_indices.include?(index)
        raise NotSearchableObject,
              "#{index} is not included in our known indexes: #{all_searchable_indices}"
      end

      index
    end

    def self.mappings_by_object_type(clz)
      document_type = clz.name.underscore
      properties = MAPPINGS_BY_OBJECT[document_type.to_sym]
      if properties
        {
          document_type => {
            properties:,
          },
        }
      else
        {}
      end
    end
  end
end
