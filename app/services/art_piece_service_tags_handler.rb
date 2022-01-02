module ArtPieceServiceTagsHandler
  def prepare_tags_params
    return unless @params[:tag_ids]

    tag_ids = @params[:tag_ids].compact_blank.map(&:downcase).uniq
    @params[:tags] = tag_ids.map do |id_or_name|
      # find or create by doesn't work here because
      # we want to find by id and create by name
      found = ArtPieceTag.where(id: id_or_name).or(ArtPieceTag.where(name: id_or_name)).limit(1).take
      found || ArtPieceTag.create(name: id_or_name)
    end.uniq
    @params.delete(:tag_ids)
    @params
  end
end
