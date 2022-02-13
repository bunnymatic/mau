require 'vcr'
require 'uri'

driver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }

VCR.configure do |c|
  c.ignore_localhost = true
  c.ignore_hosts 'mission-artists-test.s3.amazonaws.com'
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_hosts(*driver_hosts + ['maps.googleapis.com', 'geocoder.us'])
end
