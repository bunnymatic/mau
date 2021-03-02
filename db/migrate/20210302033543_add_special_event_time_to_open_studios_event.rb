class AddSpecialEventTimeToOpenStudiosEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :open_studios_events, :special_event_start_date, :datetime
    add_column :open_studios_events, :special_event_end_date, :datetime
    add_column :open_studios_events, :special_event_start_time, :string, default: '12:00 PM'
    add_column :open_studios_events, :special_event_end_time, :string, default: '4:00 PM'
  end
end
