# frozen_string_literal: true

class DeprecateOsParticipationColumnOnArtistInfo < ActiveRecord::Migration[5.2]
  def change
    rename_column :artist_infos, :open_studios_participation, :deprecated_open_studios_participation
  end
end
