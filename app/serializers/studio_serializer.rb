class StudioSerializer < MauSerializer
  attributes :name, :street_address, :city, :map_url, :url, :slug

  include Rails.application.routes.url_helpers
  include ActionView::Helpers::UrlHelper

  has_many :artists, class: StudioArtistSerializer do
    data do
      @object.artists.active
    end

    meta do
      { count: @object.artists.active.count }
    end
  end

  attribute :url do
    studio_path(@object) unless @object.is_a? IndependentStudio
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
