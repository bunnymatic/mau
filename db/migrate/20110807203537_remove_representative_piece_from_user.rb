class RemoveRepresentativePieceFromUser < ActiveRecord::Migration
  def self.up
    remove_column :users, :representative_art_piece
  end

  def self.down
    add_column :users, :representative_art_piece, :integer
  end
end
