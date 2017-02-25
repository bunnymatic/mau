# frozen_string_literal: true
class ArtistFavoritePresenter
  attr_reader :artist, :favorite

  def initialize(favorite)
    @favorite = favorite
    @artist = SimpleDelegator.new(ArtistPresenter.new(@favorite.to_obj))
  end
end
