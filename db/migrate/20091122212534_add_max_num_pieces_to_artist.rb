class AddMaxNumPiecesToArtist < ActiveRecord::Migration
  def self.up
    add_column :artists, :max_pieces, :integer, :default => 20
  end

  def self.down
    drop_column :artists, :max_pieces
  end
end
