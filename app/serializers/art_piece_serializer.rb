class ArtPieceSerializer < MauSerializer
  attributes :artist_name,
             :favorites_count,
             :price,
             :display_price,
             :year,
             :dimensions,
             :title,
             :artist_id,
             :image_urls,
             :sold_at

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper
  include ActionView::Helpers::NumberHelper

  attribute :image_urls do
    @object.images
  end

  has_one :artist

  has_many :tags

  has_one :medium

  attribute :display_price do
    @object.price && number_to_currency(@object.price)
  end

  attribute :artist_name do
    @object.artist.get_name(escape: true)
  end

  attribute :favorites_count do
    ct = Favorite.art_pieces.where(favoritable_id: @object.id).count
    ct if ct.positive?
  end
end
