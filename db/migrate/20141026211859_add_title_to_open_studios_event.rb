class AddTitleToOpenStudiosEvent < ActiveRecord::Migration
  def change
    add_column :open_studios_events, :title, :string, null: false, default: "Open Studios"
  end
end
