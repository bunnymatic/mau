# frozen_string_literal: true

class RenameColumnZipToZipcodeOnStudios < ActiveRecord::Migration[6.0]
  def change
    rename_column :studios, :zip, :zipcode
  end
end
