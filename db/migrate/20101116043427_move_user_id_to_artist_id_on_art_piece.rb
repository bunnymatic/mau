class MoveUserIdToArtistIdOnArtPiece < ActiveRecord::Migration
  def self.up
    rename_column :art_pieces, :user_id, :artist_id
  end

  def self.down
    rename_column :art_pieces, :artist_id, :user_id
  end
end
