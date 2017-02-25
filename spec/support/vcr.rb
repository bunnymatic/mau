# frozen_string_literal: true
require 'vcr'

VCR.configure do |c|
  c.ignore_localhost = true
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock # or :fakeweb
end

