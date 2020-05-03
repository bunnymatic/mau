# frozen_string_literal: true

class RenameColumnZipToZipcodeOnArtistInfo < ActiveRecord::Migration[6.0]
  def change
    rename_column :artist_infos, :zip, :zipcode
  end
end
