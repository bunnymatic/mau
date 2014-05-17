class AddMoreLinkFieldsToArtistInfo < ActiveRecord::Migration
  def change
    add_column :artist_infos, :pinterest, :string, :limit => 255
    add_column :artist_infos, :instagram, :string, :limit => 255
  end
end
