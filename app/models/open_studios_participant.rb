class OpenStudiosParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :open_studios_event

  validates :user, uniqueness: { scope: :open_studios_event }

  validates :shop_url, url: true
  validates :video_conference_url, url: true
end
