# frozen_string_literal: true
class UpdateArtPieceService
  attr_reader :art_piece, :params

  include ArtPieceServiceTagsHandler

  def initialize(art_piece, art_piece_params)
    @art_piece = art_piece
    @params = art_piece_params
  end

  def update_art_piece
    prepare_tags_params
    art_piece.update_attributes(params)
    art_piece
  end
end
