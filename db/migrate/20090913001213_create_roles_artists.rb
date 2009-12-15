class CreateRolesArtists < ActiveRecord::Migration
  def self.up
    create_table :roles_artists, :id => false do |t|
      t.integer :role_id
      t.integer :artist_id
    end
  end

  def self.down
    drop_table :roles_artists
  end
end
