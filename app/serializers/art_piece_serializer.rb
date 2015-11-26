class ArtPieceSerializer < MauSerializer
  attributes :id, :artist, :medium, :tags, :artist_name, :favorites_count, :year, :dimensions, :filename, :title, :artist_id, :image_urls

  # note: image_urls used by angular photo browser
  include HtmlHelper
  include ImageFileHelpers

  def image_urls
    debugger if object.id.to_i == 232
    urls = {}
    if object.photo?
      urls = MauImage::Paperclip::STANDARD_STYLES.keys.inject({}) do |memo, key|
        memo[key] = object.photo(key)
        memo
      end
      urls[:original] = object.photo.url
    else
      urls = object.image_paths
    end
    urls.inject({}) do |memo, (sz, path)|
      memo[sz] = full_image_path(path)
      memo
    end
  end

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
