class OpenStudiosParticipantPresenter
  include OpenStudiosParticipantsHelper
  attr_reader :participant

  delegate :video_conference_time_slots, :youtube_url, :show_email?, :shop_url, to: :participant
  def initialize(open_studios_participant)
    @participant = open_studios_participant
  end

  def show_phone?
    participant.show_phone_number? && artist.phone.present?
  end

  def conference_time_slots
    video_conference_time_slots.map { |s| display_time_slot(s, compact: true) }
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

  def artist
    @artist ||= participant.user
  end
end
