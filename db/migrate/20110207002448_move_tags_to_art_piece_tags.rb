class MoveTagsToArtPieceTags < ActiveRecord::Migration
  def self.up
    rename_table :tags, :art_piece_tags
    rename_column :art_pieces_tags, :tag_id, :art_piece_tag_id
  end

  def self.down
    rename_column :art_pieces_tags, :art_piece_tag_id, :tag_id
    rename_table :art_piece_tags, :tags
  end
end
