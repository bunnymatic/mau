# frozen_string_literal: true

class ArtistSerializer < MauSerializer
  attributes :full_name, :doing_open_studios, :profile_images,
             :url, :studio_id,
             :street_address, :city, :map_url, :firstname, :lastname,
             :nomdeplume, :slug, :art_pieces, :artist_info, :link

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  INDEX_WITH_ID = %i[id].freeze
  attribute :art_pieces do
    @object.art_pieces.map { |a| INDEX_WITH_ID.index_with { |k| a.send(k) } }
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
