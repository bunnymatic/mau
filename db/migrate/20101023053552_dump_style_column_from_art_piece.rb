class DumpStyleColumnFromArtPiece < ActiveRecord::Migration
  def self.up
    remove_column :art_pieces, :style
  end

  def self.down
    # unused - no rollback
  end
end
