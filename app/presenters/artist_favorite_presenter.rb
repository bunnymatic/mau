class ArtistFavoritePresenter
  attr_reader :artist, :favorite

  def initialize(favorite)
    @favorite = favorite
    @artist = ArtistPresenter.new(@favorite.favoritable)
  end
end
