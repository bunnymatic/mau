class OpenStudiosParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :open_studios_event

  validates :user, uniqueness: { scope: :open_studios_event }
end
