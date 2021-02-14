require 'factory_bot'
require 'faker'

Dir[Rails.root.join('spec/factories/**/*.rb')].sort.each { |f| require f }

ActionMailer::Base.perform_deliveries = false

require_relative 'sample_data/users'
require_relative 'sample_data/studios'
require_relative 'sample_data/open_studios'

puts 'Loaded sample data 🌈'
