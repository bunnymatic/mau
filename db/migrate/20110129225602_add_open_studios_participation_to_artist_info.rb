class AddOpenStudiosParticipationToArtistInfo < ActiveRecord::Migration
  def self.up
    add_column :artist_infos, :open_studios_participation, :string
  end

  def self.down
    remove_column :artist_infos, :open_studios_participation
  end
end
