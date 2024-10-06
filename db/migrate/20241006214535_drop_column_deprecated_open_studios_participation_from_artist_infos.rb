class DropColumnDeprecatedOpenStudiosParticipationFromArtistInfos < ActiveRecord::Migration[7.1]
  def change
    remove_column :artist_infos, :deprecated_open_studios_participation, :string, null: true
  end
end
