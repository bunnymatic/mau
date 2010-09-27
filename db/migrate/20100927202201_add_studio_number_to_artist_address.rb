class AddStudioNumberToArtistAddress < ActiveRecord::Migration
  def self.up
    add_column :artists, :studionumber, :integer
  end

  def self.down
    remove_column :artists, :studionumber
  end
end
