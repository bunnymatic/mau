class RemoveFilenameFromArtPieces < ActiveRecord::Migration[5.0]
  def change
    remove_column :art_pieces, :filename, :string
  end
end
