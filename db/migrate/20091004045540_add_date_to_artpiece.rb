class AddDateToArtpiece < ActiveRecord::Migration
  def self.up
    add_column :art_pieces, :year, :integer
  end

  def self.down
    remove_column :art_pieces, :year, :integer
  end
end
