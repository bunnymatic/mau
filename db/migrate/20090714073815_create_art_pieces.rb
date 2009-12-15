class CreateArtPieces < ActiveRecord::Migration
  def self.up
    create_table :art_pieces do |t|
      t.string :filename
      t.string :title
      t.text :description
      t.string :medium
      t.string :style
      t.string :dimensions
      t.integer :artist_id
      t.timestamps
    end
  end

  def self.down
    drop_table :art_pieces
  end
end

