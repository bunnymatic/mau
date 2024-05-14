class RemoveOpenStudiosActiveFlag < ActiveRecord::Migration[7.1]
  def change
    remove_column :site_preferences, :open_studios_active, :boolean
  end
end
