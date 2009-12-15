class AddHtWdToArtPiece < ActiveRecord::Migration
  def self.up
    add_column :art_pieces, :image_height, :integer, :default => 0
    add_column :art_pieces, :image_width, :integer, :default => 0

    add_column :artists, :image_height, :integer, :default => 0
    add_column :artists, :image_width, :integer, :default => 0

  end

  def self.down
    remove_column :art_pieces, :image_height
    remove_column :art_pieces, :image_width
    remove_column :artists, :image_height
    remove_column :artists, :image_width

  end
end
