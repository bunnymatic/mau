class AddUniqIndexOnArtistInfoArtistId < ActiveRecord::Migration

  def change
    remove_index :artist_infos, :artist_id
    add_index :artist_infos, :artist_id, :unique => true
  end
end
