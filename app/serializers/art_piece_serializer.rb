# frozen_string_literal: true

class ArtPieceSerializer < MauSerializer
  attributes :artist_name, :favorites_count,
             :year, :dimensions, :title, :artist_id, :image_urls

  # note: image_urls used by angular photo browser
  include ImageFileHelpers
  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  attribute :image_urls do
    urls = if @object.photo?
             (MauImage::Paperclip::STANDARD_STYLES.keys + [:original]).index_with do |key|
               @object.photo.url(key, timestamp: false)
             end
           else
             @object.image_paths
           end

    urls.each_with_object({}) do |(sz, path), memo|
      memo[sz] = path
    end
  end

  has_one :artist

  has_many :tags

  has_one :medium

  attribute :artist_name do
    @object.artist.get_name(true)
  end

  attribute :favorites_count do
    ct = Favorite.art_pieces.where(favoritable_id: @object.id).count
    ct if ct.positive?
  end
end
