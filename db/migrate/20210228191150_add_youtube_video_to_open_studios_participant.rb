class AddYoutubeVideoToOpenStudiosParticipant < ActiveRecord::Migration[6.1]
  def change
    add_column :open_studios_participants, :youtube_url, :string
  end
end
