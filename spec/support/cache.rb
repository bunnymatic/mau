require 'dalli'

RSpec.configure do |config|
  config.after(:all) do
    Rails.cache.clear
  end
end
