# == Schema Information
#
# Table name: art_pieces_tags
#
#  art_piece_tag_id :integer
#  art_piece_id     :integer
#

class ArtPiecesTag < ActiveRecord::Base
  belongs_to :art_piece
  belongs_to :art_piece_tag
end
