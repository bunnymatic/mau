class ArtPieceHtmlPresenter < ArtPiecePresenter

  def initialize(art_piece)
    super
  end

  def artist
    ArtistPresenter.new(art_piece.artist)
  end

  def angular_config
    {
      artPieceId: art_piece.id,
      artistId: artist.id
    }.to_json
  end

end
