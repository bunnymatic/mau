# frozen_string_literal: true

RSpec.configure do |config|
  config.include FactoryBot::Syntax::Methods

  FactoryBot.allow_class_lookup = false
end
