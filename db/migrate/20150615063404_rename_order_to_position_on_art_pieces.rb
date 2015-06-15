class RenameOrderToPositionOnArtPieces < ActiveRecord::Migration
  def change
    rename_column :art_pieces, :order, :position
  end
end
