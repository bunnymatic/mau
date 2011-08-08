class RemoveRepresentativeArtPieceFromArtistInfo < ActiveRecord::Migration
  def self.up
    remove_column :artist_infos, :representative_art_piece
  end

  def self.down
    add_column :artist_infos, :representative_art_piece, :integer
  end
end
