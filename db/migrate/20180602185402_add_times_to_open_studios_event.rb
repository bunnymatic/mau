class AddTimesToOpenStudiosEvent < ActiveRecord::Migration[5.1]
  def change
    add_column :open_studios_events, :start_time, :string, default: "noon"
    add_column :open_studios_events, :end_time, :string, default: "6p"
  end
end
