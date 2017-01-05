module ArtPieceServiceTagsHandler
  def prepare_tags_params
    key = :tags if @params.has_key? :tags
    return unless key
    base_names = (@params[:tags] || '').split(",").map { |name|
      if name.present?
        name.strip.downcase
      end
    }.compact.uniq
    @params[:tags] = base_names.map { |name|
      ArtPieceTag.find_or_create_by(name: name)
    }
  end
end
