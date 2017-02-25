# frozen_string_literal: true
class StudioSerializer < MauSerializer
  attributes :id, :name, :street_address, :city, :map_url, :url, :artists, :slug

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  def artists
    object.artists.active.map { |a| Hash[[:id, :slug, :full_name, :firstname, :lastname].map { |k| [k, a.send(k)] }] }
  end

  def url
    studio_path(object) unless object.is_a? IndependentStudio
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
