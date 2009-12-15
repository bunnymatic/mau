class RemoveMediumIdFromArtPiece < ActiveRecord::Migration
  def self.up
    remove_column :art_pieces, :medium_id 
  end

  def self.down
    add_column :art_pieces, :medium_id, :integer
  end
end
