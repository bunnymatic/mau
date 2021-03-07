class AddSpecialEventTimeSlotsToOpenStudiosEvent < ActiveRecord::Migration[6.1]
  def change
    add_column :open_studios_events, :special_event_time_slots, :text, array: true
  end
end
