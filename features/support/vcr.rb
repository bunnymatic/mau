# frozen_string_literal: true
require 'vcr'

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_request do |request|
    uri = URI(request.uri)

    uri.host == 'maps.googleapis.com' || uri.host == 'geocoder.us'
  end
end

