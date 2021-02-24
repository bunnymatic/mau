class AddFieldsToOpenStudiosParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :open_studios_participants, :shop_url, :string
    add_column :open_studios_participants, :video_conference_url, :string
    add_column :open_studios_participants, :show_email, :boolean
    add_column :open_studios_participants, :show_phone_number, :boolean
  end
end
