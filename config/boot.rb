# frozen_string_literal: true

ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require 'bundler/setup' # Set up gems listed in the Gemfile.
begin
  require 'bootsnap/setup'
rescue LoadError
  puts 'Failed to load bootsnap'
end
