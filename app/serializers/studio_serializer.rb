class StudioSerializer < MauSerializer
  attributes :id, :name, :street_address, :city, :map_url, :url, :artists, :slug

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def artists
    object.artists.active.map{|a| Hash[[:id, :slug, :full_name, :firstname, :lastname].map{|k| [k, a.send(k)]}]}
  end

  def url
    unless object.is_a? IndependentStudio
      studio_path(object)
    end
  end

  def street_address
    address = object.address_hash.parsed.street
  end

  def city
    address = object.address_hash.parsed.city
  end

  def map_url
    object.map_link
  end

end
