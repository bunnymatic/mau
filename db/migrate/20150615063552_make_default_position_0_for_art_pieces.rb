class MakeDefaultPosition0ForArtPieces < ActiveRecord::Migration
  def change
    change_column :art_pieces, :position, :integer, default: 0
  end
end
