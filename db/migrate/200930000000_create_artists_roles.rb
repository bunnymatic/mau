class CreateArtistsRoles < ActiveRecord::Migration
  def self.up
    create_table :artists_roles, :id => false do |t|
      t.integer :artist_id
      t.integer :role_id
    end
  end

  def self.down
    drop_table :artists_roles
  end
end
