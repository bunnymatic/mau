# frozen_string_literal: true

class MoveArtistToUser < ActiveRecord::Migration
  # list of columns to move from artist to the new artist_info table
  COLUMNS_TO_MOVE = [
    { name: 'bio', type: 'text', args: {} },
    { name: 'news', type: 'text', args: {} },
    { name: 'street', type: :string, args: {} },
    { name: 'city', type: :string, args: { limit: 200 } },
    { name: 'addr_state', type: :string, args: { limit: 4 } },
    { name: 'facebook', type: :string, args: { limit: 200 } },
    { name: 'twitter', type: :string, args: { limit: 200 } },
    { name: 'blog', type: :string, args: { limit: 200 } },
    { name: 'myspace', type: :string, args: { limit: 200 } },
    { name: 'flickr', type: :string, args: { limit: 200 } },
    { name: 'zip', type: :integer, args: {} },
    { name: 'max_pieces', type: :integer, args: { default: 20 } },
    { name: 'representative_art_piece', type: :integer, args: {} },
    { name: 'studionumber', type: :string, args: {} },
    { name: 'osoct2010', type: :boolean, args: { default: false } },
    { name: 'os2010', type: :boolean, args: { default: false } },
    { name: 'lat', type: :float, args: {} },
    { name: 'lng', type: :float, args: {} },
  ].freeze

  def self.up
    create_table :artist_infos do |t|
      t.integer :artist_id
      t.timestamps
      COLUMNS_TO_MOVE.each do |c|
        t.send(c[:type], c[:name], c[:args])
      end
    end

    rename_table :artists, :users
    rename_column :art_pieces, :artist_id, :user_id
    rename_table :artists_roles, :roles_users
    rename_column :roles_users, :artist_id, :user_id
    add_column :users, :type, :string, default: 'Artist'

    # copy data from users to artist_info
    fieldnames = COLUMNS_TO_MOVE.map { |c| '`%s`' % c[:name] }.join(',')
    srcfieldnames = fieldnames + ', id, created_at'
    destfieldnames = fieldnames + ', artist_id, created_at'
    execute "insert ignore into artist_infos(#{destfieldnames}) select #{srcfieldnames} from users"
  end

  def self.down
    remove_column :users, :type
    rename_column :roles_users, :user_id, :artist_id
    rename_table :roles_users, :artists_roles
    rename_column :art_pieces, :user_id, :artist_id
    rename_table :users, :artists
    drop_table :artist_infos
  end
end
