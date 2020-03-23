# frozen_string_literal: true

class MakeLatLngDoubleOnArtistInfos < ActiveRecord::Migration[6.0]
  def change
    change_column :artist_infos, :lat, :double
    change_column :artist_infos, :lng, :double
  end
end
