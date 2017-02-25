# frozen_string_literal: true
require 'geokit'

Geokit::Geocoders::GoogleGeocoder.api_key = Conf.ga_server_api_key
Geokit::Geocoders.request_timeout = 3

Geokit::Geocoders.provider_order = if Rails.env.test?
                                     [:fake]
                                   else
                                     [:google]
                                   end
