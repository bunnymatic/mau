# frozen_string_literal: true
module LeakyFixtures
  def fix_leaky_fixtures
    # hopefully we can get around this but until we see what's up
    [ ArtPiece, User, Studio, ArtistInfo ].each do |clz|
      clz.destroy_all if clz.count > 0
    end
  end
end

RSpec.configure do |config|
  config.include LeakyFixtures
end
