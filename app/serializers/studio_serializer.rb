class StudioSerializer < MauSerializer
  attributes :name, :slug

  include ActionView::Helpers::UrlHelper

  has_many :artists, meta: proc { |studio, _params| { count: studio.artists.active.count } }

  attribute :url do |object|
    Rails.application.routes.url_helpers.studio_path(object) unless object.is_a? IndependentStudio
  end

  attribute :street_address do |object|
    object.address.street
  end

  attribute :city do |object|
    object.address.city
  end

  attribute :map_url, &:map_link
end
