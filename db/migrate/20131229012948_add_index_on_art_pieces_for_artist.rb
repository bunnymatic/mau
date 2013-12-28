class AddIndexOnArtPiecesForArtist < ActiveRecord::Migration
  def change
    add_index :art_pieces, :artist_id
  end
end
