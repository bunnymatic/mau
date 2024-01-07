class UpdateArtPieceService
  attr_reader :art_piece, :params

  include ArtPieceServiceTagsHandler

  def initialize(art_piece, art_piece_params)
    @art_piece = art_piece
    @params = art_piece_params
  end

  def update_art_piece
    prepare_tags_params
    art_piece.update(params)
    art_piece.tap { trigger_artist_update }
  end

  def trigger_artist_update
    BryantStreetStudiosWebhook.artist_updated(@art_piece.artist.id)
  end
end
