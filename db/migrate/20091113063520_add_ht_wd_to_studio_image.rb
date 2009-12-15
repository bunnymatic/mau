class AddHtWdToStudioImage < ActiveRecord::Migration
  def self.up
    add_column :studios, :image_height, :integer, :default => 0
    add_column :studios, :image_width, :integer, :default => 0
  end

  def self.down
    remove_column :studios, :image_height
    remove_column :studios, :image_width
  end
end
