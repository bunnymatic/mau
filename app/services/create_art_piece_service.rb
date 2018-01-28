# frozen_string_literal: true

class CreateArtPieceService
  attr_reader :params, :artist

  include ArtPieceServiceTagsHandler

  def initialize(artist, art_piece_params)
    @params = art_piece_params
    @artist = artist
  end

  def create_art_piece
    prepare_tags_params
    art_piece = artist.art_pieces.build(params)
    art_piece.save
    art_piece
  end
end
