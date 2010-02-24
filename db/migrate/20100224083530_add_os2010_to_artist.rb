class AddOs2010ToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :os2010, :boolean, :default => false
  end

  def self.down
    remove_column :artists, :os2010
  end
end
