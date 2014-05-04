class ArtPieceHtmlPresenter < ArtPiecePresenter

  def initialize(view_context,art_piece)
    super
  end

  def angular_config
    {
      artPieceId: art_piece.id,
      artistId: artist.id
    }.to_json
  end

end
