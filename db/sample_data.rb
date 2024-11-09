require 'factory_bot'
require 'faker'

Rails.root.glob('spec/factories/**/*.rb').each { |f| require f }

ActionMailer::Base.perform_deliveries = false

require './spec/support/fake_geocoder' if Rails.env.test?

require_relative 'sample_data/users'
require_relative 'sample_data/studios'
require_relative 'sample_data/open_studios'

puts 'Loaded sample data 🌈'
