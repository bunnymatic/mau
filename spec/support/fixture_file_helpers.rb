module FixtureFileHelpers
  def fixture_file(file)
    Rails.root.join("spec/fixtures/#{file}")
  end
end

RSpec.configure do |config|
  config.include FixtureFileHelpers
end
