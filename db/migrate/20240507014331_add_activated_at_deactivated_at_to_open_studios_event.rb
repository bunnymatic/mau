class AddActivatedAtDeactivatedAtToOpenStudiosEvent < ActiveRecord::Migration[7.1]
  def change
    add_column :open_studios_events, :activated_at, :date, null: true
    add_column :open_studios_events, :deactivated_at, :date, null: true
  end
end
