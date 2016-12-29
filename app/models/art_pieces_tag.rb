class ArtPiecesTag < ApplicationRecord
  belongs_to :art_piece, inverse_of: :art_pieces_tags
  belongs_to :art_piece_tag, inverse_of: :art_pieces_tags
end
