require 'dotenv'
Dotenv.load
require 'webdrivers'
require './spec/support/simplecov'
require './spec/support/faker_files'
require 'cucumber/rails'
require 'factory_bot'
require 'capybara/rspec'
require 'capybara-screenshot/cucumber'

Rails.root.glob('spec/factories/**/*.rb').each { |f| require f }
Rails.root.glob('features/support/**/*.rb').each { |f| require f }

require './spec/support/fake_geocoder'

Capybara.configure do |config|
  config.always_include_port = true
end
