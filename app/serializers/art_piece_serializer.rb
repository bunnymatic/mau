class ArtPieceSerializer < MauSerializer
  attributes :id, :artist, :medium, :tags, :artist_name, :favorites_count,
             :year, :dimensions, :filename, :title, :artist_id, :image_urls

  # note: image_urls used by angular photo browser
  include ImageFileHelpers
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def image_urls
    urls = {}
    if object.photo?
      urls = (MauImage::Paperclip::STANDARD_STYLES.keys + [:original]).inject({}) do |memo, key|
        memo[key] = object.photo.url(key, timestamp: false)
        memo
      end
    else
      urls = object.image_paths
    end

    urls.inject({}) do |memo, (sz, path)|
      memo[sz] = path
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
        tag_attrs.each {|t| t['name'] = HtmlEncoder.encode t['name']}
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
