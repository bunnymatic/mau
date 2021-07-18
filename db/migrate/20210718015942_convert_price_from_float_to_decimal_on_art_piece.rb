class ConvertPriceFromFloatToDecimalOnArtPiece < ActiveRecord::Migration[6.1]
  def change
    change_column :art_pieces, :price, :decimal, precision: 10, scale: 2
  end
end
