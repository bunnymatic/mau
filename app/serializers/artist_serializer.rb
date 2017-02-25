# frozen_string_literal: true
class ArtistSerializer < MauSerializer
  attributes :full_name, :doing_open_studios, :profile_images,
             :id, :url, :studio_id,
             :street_address, :city, :map_url, :firstname, :lastname,
             :nomdeplume, :slug, :art_pieces, :artist_info, :link

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def art_pieces
    object.art_pieces.map { |a| Hash[[:id].map { |k| [k, a.send(k)] }] }
  end

  def link
    artist_path(object)
  end

  def street_address
    address = object.address.street
  end

  def city
    address = object.address.city
  end

  def map_url
    object.map_link
  end
end
