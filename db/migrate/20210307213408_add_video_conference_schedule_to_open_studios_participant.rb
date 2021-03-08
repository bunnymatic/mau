class AddVideoConferenceScheduleToOpenStudiosParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :open_studios_participants, :video_conference_schedule, :text
  end
end
