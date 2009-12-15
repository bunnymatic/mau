class DelRolesArtists < ActiveRecord::Migration
  def self.up
    drop_table :roles_artists
  end

  def self.down
  end
end
