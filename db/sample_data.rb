# coding: utf-8
# frozen_string_literal: true
require 'factory_bot'
require 'faker'

Dir[Rails.root.join('spec', 'factories', '**', '*.rb')].each { |f| require f }

require_relative 'sample_data/users'
require_relative 'sample_data/studios'
require_relative 'sample_data/open_studios'

puts 'Loaded sample data 🌈'
