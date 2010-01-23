class RemoveActiveFromArtists < ActiveRecord::Migration
  def self.up
    remove_column :artists, :active
  end

  def self.down
    add_column :artists, :active, :boolean, :default => 1
  end
end
