class AddTimestampsToOpenStudiosParticipants < ActiveRecord::Migration[6.1]
  def change
    add_timestamps :open_studios_participants, default: DateTime.now
    change_column_default :open_studios_participants, :created_at, from: DateTime.now, to: nil
    change_column_default :open_studios_participants, :updated_at, from: DateTime.now, to: nil
  end
end
