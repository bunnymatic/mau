# frozen_string_literal: true

class AddIndexToOpenStudiosEventsKey < ActiveRecord::Migration[5.2]
  def change
    add_index :open_studios_events, :key, unique: true
  end
end
