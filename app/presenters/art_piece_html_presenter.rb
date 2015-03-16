class ArtPieceHtmlPresenter < ArtPiecePresenter
  def artist
    ArtistPresenter.new(art_piece.artist)
  end
end
