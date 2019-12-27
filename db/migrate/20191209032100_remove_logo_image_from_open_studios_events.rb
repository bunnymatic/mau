# frozen_string_literal: true

class RemoveLogoImageFromOpenStudiosEvents < ActiveRecord::Migration[5.2]
  def change
    remove_attachment :open_studios_events, :logo
  end
end
