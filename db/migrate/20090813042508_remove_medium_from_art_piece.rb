class RemoveMediumFromArtPiece < ActiveRecord::Migration
  def self.up
    remove_column :art_pieces, :medium
  end

  def self.down
    add_column :art_pieces, :medium, :string
  end
end
