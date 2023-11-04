require 'vcr'
require 'uri'

driver_hosts = Webdrivers::Common.subclasses.map { |driver| URI(driver.base_url).host }

driver_hosts += [
  'chromedriver.storage.googleapis.com',
  'googlechromelabs.github.io',
  'edgedl.me.gvt1.com',
  'maps.googleapis.com',
  'geocoder.us',
  'mission-artists-test.s3.amazonaws.com',
]

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
  c.ignore_hosts(*driver_hosts)
end
