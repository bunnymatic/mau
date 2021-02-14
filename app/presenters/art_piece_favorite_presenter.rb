class ArtPieceFavoritePresenter
  attr_reader :art_piece, :favorite

  def initialize(favorite)
    @favorite = favorite
    @art_piece = SimpleDelegator.new(ArtPiecePresenter.new(@favorite.favoritable))
  end
end
