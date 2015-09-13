class SearchService

  class ObjectSearchService
    attr_reader :object
    def initialize(object)
      @object = object
    end

    def index
      object.__elasticsearch__.index_document
    end

    def reindex
      object.__elasticsearch__.delete_document
      object.__elasticsearch__.index_document
    end

    def remove
      object.__elasticsearch__.delete_document
    end

    def update
      object.__elasticsearch__.update_document
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

  def self.run_es_method_on_object(method, object)
    case object.class.name
    when Studio.name
      StudioSearchService.new(object).send(method)
    when Artist.name
      ArtistSearchService.new(object).send(method)
    when ArtPiece.name
      ArtPieceSearchService.new(object).send(method)
    end
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
