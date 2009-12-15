class RemoveArtistsTagsMedia < ActiveRecord::Migration
  def self.up
    drop_table :artists_tags
    drop_table :artists_media
    drop_table :art_pieces_media
    add_column :art_pieces, :medium_id, :integer
    create_table "art_pieces_tags", :id => false, :force => true do |t|
      t.integer "tag_id"
      t.integer "art_piece_id"
    end
  end

  def self.down
    create_table "artists_tags", :id => false, :force => true do |t|
      t.integer "tag_id"
      t.integer "artist_id"
    end
    create_table "artists_media", :id => false, :force => true do |t|
      t.integer "medium_id"
      t.integer "artist_id"
    end
    create_table "art_pieces_media", :id => false, :force => true do |t|
      t.integer "medium_id"
      t.integer "art_piece_id"
    end
    remove_column :art_piece, :medium_id
    remove_table :art_pieces_tags
  end
end
