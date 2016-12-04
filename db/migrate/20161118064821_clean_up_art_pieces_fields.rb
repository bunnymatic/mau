class CleanUpArtPiecesFields < ActiveRecord::Migration

  def up
    if ActiveRecord::Base.connection.column_exists?(:art_pieces, :description)
      change_table :art_pieces do |t|
        t.remove :description
      end
    end
  end

  def down
    change_table :art_pieces do |t|
      t.column :description, :text
    end
  end

end
