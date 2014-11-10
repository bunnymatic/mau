class AddLogoToOpenStudiosEvents < ActiveRecord::Migration
  def change
    add_attachment :open_studios_events, :logo
  end
end
