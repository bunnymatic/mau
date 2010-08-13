class AddOctos2010ToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :osoct2010, :boolean, :default => false
  end

  def self.down
    remove_column :artists, :osoct2010
  end
end
