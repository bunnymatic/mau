class AddPriceToArtPiece < ActiveRecord::Migration[6.1]
  def change
    add_column :art_pieces, :price, :float
  end
end
