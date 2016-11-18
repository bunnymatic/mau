class CleanUpArtPiecesFields < ActiveRecord::Migration

  def up
    change_table :art_pieces do |t|
      t.remove :description
    end
  end

  def down
    change_table :art_pieces do |t|
      t.column :description, :text
    end
  end

end
