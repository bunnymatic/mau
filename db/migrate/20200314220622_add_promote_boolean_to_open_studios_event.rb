# frozen_string_literal: true

class AddPromoteBooleanToOpenStudiosEvent < ActiveRecord::Migration[5.2]
  def change
    add_column :open_studios_events, :promote, :boolean, default: true, null: false
  end
end
