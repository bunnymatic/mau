require 'faker'
require 'geokit'

module Geokit
  module Geocoders
    class FakeGeocoder < Geocoder
      def self.geocode(_location, _opts = {})
        # return a GeoLoc instance
        valid_data = {
          :street_address => Faker::Address.street_name,
          :city => Faker::Address.city,
          :state => Faker::Address.state,
          :zip => Faker::Address.zip_code,
          :lat => 37,
          :lng => -122,
        }
        g = Geokit::GeoLoc.new(valid_data)
        g.success = true
        g
      end
    end
  end
end
