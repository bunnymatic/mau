class RequireArtistForArtPieceAndArtistInfo < ActiveRecord::Migration
  def change
    change_column_null :art_pieces, :artist_id, true
    change_column_null :artist_infos, :artist_id, true

    remove_index :artist_infos, :artist_id
    add_index :artist_infos, :artist_id, unique: true
  end

end
