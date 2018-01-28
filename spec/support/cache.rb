# frozen_string_literal: true

require 'dalli'

RSpec.configure do |config|
  config.before(:each) do
    Rails.cache.clear
  end

  config.after(:all) do
    Rails.cache.clear
  end
end
