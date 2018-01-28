# frozen_string_literal: true

module LeakyFixtures
  def fix_leaky_fixtures
    # hopefully we can get around this but until we see what's up
    [ArtPiece, User, Studio, ArtistInfo].each do |clz|
      if clz.count > 0
        puts "*********** Cleaning up what looks like leaky #{clz.name} fixtures"
        clz.destroy_all
      end
    end
  end
end

RSpec.configure do |config|
  config.include LeakyFixtures
end
