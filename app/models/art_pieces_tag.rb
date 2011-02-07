class ArtPiecesTag < ActiveRecord::Base
  belongs_to :art_piece
  belongs_to :art_piece_tag
end
