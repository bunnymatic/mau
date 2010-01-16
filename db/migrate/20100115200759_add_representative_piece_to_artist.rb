class AddRepresentativePieceToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :representative_art_piece, :integer
  end

  def self.down
    remove_column :artists, :representative_art_piece
  end
end
