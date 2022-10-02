class ArtistSerializer < MauSerializer
  attributes :art_pieces,
             :artist_info,
             :city,
             :doing_open_studios,
             :firstname,
             :full_name,
             :lastname,
             :link,
             :map_url,
             :nomdeplume,
             :profile_images,
             :slug,
             :street_address,
             :studio_id,
             :url

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  INDEX_WITH_ID = %i[id].freeze
  attribute :art_pieces do
    @object.art_pieces.map { |a| INDEX_WITH_ID.index_with { |k| a.send(k) } }
  end

  attribute :url do
    @object.website
  end

  attribute :link do
    artist_path(@object)
  end

  attribute :street_address do
    @object.address.street
  end

  attribute :city do
    @object.address.city
  end

  attribute :map_url do
    @object.map_link
  end
end
