class RemoveImageDimensionsFromArtistAndStudio < ActiveRecord::Migration
  def up
    remove_column :users, :image_height
    remove_column :users, :image_width
    remove_column :studios, :image_height
    remove_column :studios, :image_width
  end

  def down
    add_column :studios, :image_width, :integer, :default => 0
    add_column :studios, :image_height, :integer, :default => 0
    add_column :users, :image_width, :integer, :default => 0
    add_column :users, :image_height, :integer, :default => 0
  end
end
