class OpenStudiosParticipant < ApplicationRecord
  belongs_to :user
  belongs_to :open_studios_event

  validates :user, uniqueness: { scope: :open_studios_event }

  validates :shop_url, url: true
  validates :video_conference_url, url: true
  validates :youtube_url, youtube_url: true

  store :video_conference_schedule

  def video_conference_time_slots
    return [] unless video_conference_url && video_conference_schedule

    video_conference_schedule.select { |_timeslot, val| val }.keys
  end

  class << self
    def parse_time_slot(slot)
      start_time, end_time = slot.split('::')
      [
        Time.zone.at(start_time.to_i),
        Time.zone.at(end_time.to_i),
      ]
    end
  end
end
