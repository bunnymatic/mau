# frozen_string_literal: true

module ArtPieceServiceTagsHandler
  def prepare_tags_params
    return unless @params[:tag_ids]

    tag_ids = @params[:tag_ids].reject(&:blank?)
    @params[:tags] = tag_ids.map do |id_or_name|
      # find or create by doesn't work here because
      # we want to find by id and create by name
      ArtPieceTag.find_by(id: id_or_name) || ArtPieceTag.create(name: id_or_name)
    end
    @params.delete(:tag_ids)
    @params
  end
end
