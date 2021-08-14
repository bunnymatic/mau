class OpenStudiosParticipantPresenter
  include OpenStudiosParticipantsHelper
  attr_reader :participant

  delegate :video_conference_url, :video_conference_time_slots, :youtube_url, :show_email?, :shop_url, :updated_at, to: :participant
  def initialize(open_studios_participant)
    @participant = open_studios_participant
  end

  def address
    (@participant.user).becomes(Artist).address
  end

  def full_address
    (@participant.user).becomes(Artist).full_address
  end

  def map_link
    (@participant.user).becomes(Artist).map_link
  end

  def broadcasting?
    Time.use_zone(Conf.event_time_zone) do
      now = Time.zone.now
      time_slots.map { |s| OpenStudiosParticipant.parse_time_slot(s) }.any? do |start_time, end_time|
        now.between?(start_time, end_time)
      end
    end
  end

  def show_phone?
    @show_phone ||= participant.show_phone_number? && artist.phone.present?
  end

  def conference_time_slots
    @conference_time_slots ||= display_time_slots(time_slots, compact: true)
  end

  def has_shop? # rubocop:disable Naming/PredicateName
    participant.shop_url.present?
  end

  def has_scheduled_conference? # rubocop:disable Naming/PredicateName
    participant.video_conference_time_slots.present? && participant.video_conference_url.present?
  end

  def has_youtube? # rubocop:disable Naming/PredicateName
    participant.youtube_url.present?
  end

  private

  def time_slots
    @time_slots ||= video_conference_time_slots
  end

  def artist
    @artist ||= participant.user
  end
end
