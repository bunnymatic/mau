class RemoveImageDimensionFieldsFromArtPieces < ActiveRecord::Migration
  def up
    remove_column :art_pieces, :image_height
    remove_column :art_pieces, :image_width
  end

  def down
    add_column :art_pieces, :image_width, :integer, :default => 0
    add_column :art_pieces, :image_height, :integer, :default => 0
  end
end
