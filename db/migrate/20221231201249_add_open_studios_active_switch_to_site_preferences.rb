class AddOpenStudiosActiveSwitchToSitePreferences < ActiveRecord::Migration[6.1]
  def change
    add_column :site_preferences, :open_studios_active, :boolean
  end
end
