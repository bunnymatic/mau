class ArtPieceSerializer < MauSerializer
  attributes :id, :artist, :medium, :tags, :artist_name, :favorites_count, :image_files, :year, :dimensions, :filename, :title, :artist_id

  include HtmlHelper

  def artist
    object.artist.try(:id)
  end

  def medium
    @medium ||= object.try(:medium).try(:attributes)
  end

  def tags
    @tags ||=
      begin
        return unless object.tags.present?
        tag_attrs = object.tags.map{|t| t.attributes}
        tag_attrs.each {|t| t['name'] = html_encode t['name']}
        tag_attrs
      end
  end

  def artist_name
    @artist_name ||= object.artist.get_name(true)
  end

  def favorites_count
    @favorites_count ||= Favorite.art_pieces.where(:favoritable_id => object.id).count
    @favorites_count if @favorites_count > 0
  end

end
