module ArtPieceServiceTagsHandler
  def prepare_tags_params
    key = :tags if params.has_key? :tags
    key = :tag_ids if params.has_key? :tag_ids
    return unless key
    base_names = []
    base_tags = params.delete key
    if key == :tags
      base_names = (base_tags || '').split(",")
    else
      base_names = base_tags
    end
    ArtPieceTag.transaction do
      self.params[:tags] = base_names.map{|name| ArtPieceTag.find_or_create_by(name: name)}
    end
  end
end
