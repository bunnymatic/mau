require 'geokit'

Geokit::Geocoders::GoogleGeocoder.api_key = Conf.ga_server_api_key
Geokit::Geocoders::request_timeout = 3

if Rails.env.test?
  Geokit::Geocoders::provider_order = [:fake]
else
  Geokit::Geocoders::provider_order = [:google,:us]
end
