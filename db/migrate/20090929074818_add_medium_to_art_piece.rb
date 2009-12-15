class AddMediumToArtPiece < ActiveRecord::Migration
  def self.up
    add_column :art_pieces, :medium_id, :integer
  end

  def self.down
    remove_column :art_pieces, :medium_id
  end
end
