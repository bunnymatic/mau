# frozen_string_literal: true

class CreateOpenStudiosParticipantsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :open_studios_participants do |t|
      t.belongs_to :user, foreign_key: true, type: :integer
      t.belongs_to :open_studios_event, foreign_key: true, type: :integer
    end

    add_index(:open_studios_participants, %i[user_id open_studios_event_id], unique: true, name: 'idx_os_participants_on_user_and_open_studios_event')
  end
end
