class RemoveDescriptionFromArtPieces < ActiveRecord::Migration
  def up
    remove_column :art_pieces, :description
  end

  def down
    add_column :art_pieces, :description, :text
  end
end
