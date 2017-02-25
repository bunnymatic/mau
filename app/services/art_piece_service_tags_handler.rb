# frozen_string_literal: true
module ArtPieceServiceTagsHandler
  def prepare_tags_params
    key = :tags if @params.has_key? :tags
    return unless key
    base_names = (@params[:tags] || '').split(',').map do |name|
      name.strip.downcase if name.present?
    end.compact.uniq
    @params[:tags] = base_names.map do |name|
      ArtPieceTag.find_or_create_by(name: name)
    end
  end
end
