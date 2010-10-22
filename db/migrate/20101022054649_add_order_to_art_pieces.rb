class AddOrderToArtPieces < ActiveRecord::Migration
  def self.up
    add_column :art_pieces, :order, :integer
  end

  def self.down
    remove_column :art_piece, :order, :integer
  end
end
