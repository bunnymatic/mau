class AddActiveColumnToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :active, :boolean, :default => 1
  end

  def self.down
    remove_column :artists, :active
  end
end
