class MoveArtistToUser < ActiveRecord::Migration
  def self.up
    rename_table :artists, :users
    create_table :artists do |t|
      t.timestamps
    end
    rename_column :art_pieces, :artist_id, :user_id
    rename_table :artists_roles, :roles_users
    rename_column :roles_users, :artist_id, :user_id
  end

  def self.down
    drop_table :artists
    rename_table :users, :artists
    rename_column :art_pieces, :user_id, :artist_id

    rename_column :roles_users, :user_id, :artist_id
    rename_table :roles_users, :artists_roles
  end
end
