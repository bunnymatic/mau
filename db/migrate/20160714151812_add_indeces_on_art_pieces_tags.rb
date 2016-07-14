class AddIndecesOnArtPiecesTags < ActiveRecord::Migration
  def change
    add_index :art_pieces_tags, :art_piece_id
    add_index :art_pieces_tags, :art_piece_tag_id
  end
end
