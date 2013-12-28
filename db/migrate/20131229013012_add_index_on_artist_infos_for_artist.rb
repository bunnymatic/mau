class AddIndexOnArtistInfosForArtist < ActiveRecord::Migration
  def change
    add_index :artist_infos, :artist_id
  end
end
