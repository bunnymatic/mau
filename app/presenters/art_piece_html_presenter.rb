class ArtPieceHtmlPresenter < ArtPiecePresenter

  def initialize(view_context,art_piece)
    super
  end

  def artist
    ArtistPresenter.new(@view_context, art_piece.artist)
  end
  
  def angular_config
    {
      artPieceId: art_piece.id,
      artistId: artist.id
    }.to_json
  end

end
