SERIALIZEABLE_AR_MODELS = %i[
  Artist
  ArtPiece
  ArtPieceTag
  Email
  Medium
  Studio
].freeze

module JsonapiSerializerConcerns
  extend ActiveSupport::Concern

  def jsonapi_class
    super.merge(mau_serializer_lut)
  end

  def mau_serializer_lut
    unless @config
      @config = _generate_serializer_lut
      @config.freeze
    end
    @config
  end

  def _generate_serializer_lut
    SERIALIZEABLE_AR_MODELS.index_with { |val| "#{val}Serializer".constantize }.tap do |config|
      config[:IndependentStudio] = StudioSerializer
      config[:GenericEvent] = ApplicationEventSerializer
      config[:OpenStudiosSignupEvent] = ApplicationEventSerializer
      config[:UserChangedEvent] = ApplicationEventSerializer
    end
  end

  module ClassMethods
  end
end
