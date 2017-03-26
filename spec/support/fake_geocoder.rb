# frozen_string_literal: true
require 'faker'
require 'geokit'

module Geokit
  module Geocoders
    class FakeGeocoder < Geocoder
      def self.geocode(_location, _opts = {})
        # return a GeoLoc instance
        valid_data = {
          street_address: Faker::Address.street_name,
          city: Faker::Address.city,
          state: Faker::Address.state,
          zip: Faker::Address.zip_code,
          lat: 36.66666,
          lng: -122.22222
        }
        g = Geokit::GeoLoc.new(valid_data)
        g.success = true
        g
      end
    end
  end
end
