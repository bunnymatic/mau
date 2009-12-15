class CreateArtPiecesMedia < ActiveRecord::Migration
  def self.up
    create_table :art_pieces_media, :id => false do |t|
      t.integer :medium_id
      t.integer :art_piece_id
    end
  end

  def self.down
    drop_table :art_pieces_media
  end
end
