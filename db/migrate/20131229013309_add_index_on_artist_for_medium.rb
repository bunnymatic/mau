class AddIndexOnArtistForMedium < ActiveRecord::Migration
  def change
    add_index :art_pieces, :medium_id
  end
end
