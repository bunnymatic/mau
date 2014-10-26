class AddKeyToOpenStudiosEvent < ActiveRecord::Migration
  def change
    add_column :open_studios_events, :key, :string
  end
end
