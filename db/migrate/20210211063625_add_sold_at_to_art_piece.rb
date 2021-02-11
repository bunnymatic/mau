class AddSoldAtToArtPiece < ActiveRecord::Migration[6.1]
  def change
    add_column :art_pieces, :sold_at, :datetime
  end
end
