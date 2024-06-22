DATE_FORMAT = '%Y %b'.freeze
REVERSE_START_DATE_FORMAT = '%b %-d-'.freeze
END_DATE_WITHIN_MONTH_FORMAT = '%-d %Y'.freeze
END_DATE_OUTSIDE_MONTH_FORMAT = '%b %-d %Y'.freeze

class OpenStudiosEvent < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: true }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :dates_are_in_order
  validate :activation_dates_are_in_order
  validate :special_event_dates_are_in_order
  validate :special_event_dates_are_both_present_or_both_empty
  validate :special_event_dates_are_within_event_dates

  serialize :special_event_time_slots

  before_save :generate_special_event_time_slots

  has_many :open_studios_participants, inverse_of: :open_studios_event, dependent: :destroy
  has_many :artists, through: :open_studios_participants, class_name: 'Artist', source: :user

  has_one_attached :banner_image
  validates :banner_image, size: { less_than: 8.megabytes }, content_type: %i[png jpg jpeg gif]

  def for_display(month_first: false)
    if month_first
      date = start_date.strftime(REVERSE_START_DATE_FORMAT)
      if start_date.month == end_date.month
        date + end_date.strftime(END_DATE_WITHIN_MONTH_FORMAT)
      else
        date + end_date.strftime(END_DATE_OUTSIDE_MONTH_FORMAT)
      end
    else
      start_date.strftime(DATE_FORMAT)
    end
  end

  # define future/past not as scopes because we want Time.zone.now() to be evaluated at query time
  # Also, this allows us to test with TimesHelper as opposed to using database NOW() method
  def self.past
    where(start_date: ..Time.zone.now).order(:start_date)
  end

  def self.future
    where(end_date: Time.zone.now..).order(:start_date)
  end

  def self.activated
    where(activated_at: ..Time.zone.now).and(deactivated.invert_where).or(where(activated_at: nil))
  end

  def self.deactivated
    where(deactivated_at: ...Time.zone.now)
  end

  def self.current
    active = all.activated
    active.future.first || active.past.last
  end

  private

  SPECIAL_EVENT_FIELDS = %w[special_event_start_time special_event_end_time special_event_start_date special_event_end_date].freeze
  def generate_special_event_time_slots
    return unless changed.intersect?(SPECIAL_EVENT_FIELDS)

    if [special_event_start_date, special_event_end_date, special_event_start_time, special_event_end_time].any?(&:blank?)
      self.special_event_time_slots = []
      return
    end

    number_of_days = (special_event_end_date.to_date - special_event_start_date.to_date).to_i
    time_slots = Array.new(number_of_days + 1) do |day_offset|
      date = special_event_start_date + day_offset.days
      TimeSlotComputer.new(date, special_event_start_time, special_event_end_time).run
    end.flatten
    self.special_event_time_slots = time_slots
  end

  def dates_are_in_order
    date_fields_are_in_order(:start_date, :end_date)
  end

  def activation_dates_are_in_order
    date_fields_are_in_order(:activated_at, :deactivated_at)
  end

  def special_event_dates_are_in_order
    date_fields_are_in_order(:special_event_start_date, :special_event_end_date)
  end

  def date_fields_are_in_order(start_field, end_field)
    start_val = send(start_field)
    end_val = send(end_field)
    return unless end_val && start_val

    errors.add(end_field, "should be after #{start_field.to_s.humanize.downcase}") unless end_val >= start_val
  end

  def special_event_dates_are_both_present_or_both_empty
    return if special_event_end_date && special_event_start_date

    return unless special_event_end_date || special_event_start_date

    errors.add(:special_event_start_date, 'must be present if special event end date is present') if special_event_end_date
    errors.add(:special_event_end_date, 'must be present if special event start date is present') if special_event_start_date
  end

  def special_event_dates_are_within_event_dates
    return unless special_event_end_date && special_event_start_date

    event_range = (start_date..end_date)
    errors.add(:special_event_start_date, 'must be during the main event dates') unless event_range.cover?(special_event_start_date)
    errors.add(:special_event_end_date, 'must be during the main event dates') unless event_range.cover?(special_event_end_date)
  end
end
