DATE_FORMAT = '%Y %b'.freeze
REVERSE_START_DATE_FORMAT = '%b %-d-'.freeze
END_DATE_WITHIN_MONTH_FORMAT = '%-d %Y'.freeze
END_DATE_OUTSIDE_MONTH_FORMAT = '%b %-d %Y'.freeze

class OpenStudiosEvent < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: true }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :dates_are_in_order
  validate :special_event_dates_are_in_order
  validate :special_event_dates_are_both_present_or_both_empty
  validate :special_event_dates_are_within_event_dates

  has_many :open_studios_participants, inverse_of: :open_studios_event, dependent: :destroy
  has_many :artists, through: :open_studios_participants, class_name: 'Artist', source: :user

  def for_display(reverse: false)
    if reverse
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
    where('start_date < ?', Time.zone.now).order(:start_date)
  end

  def self.future
    where('end_date > ?', Time.zone.now).order(:start_date)
  end

  def self.current
    future.first || past.last
  end

  private

  def dates_are_in_order
    date_fields_are_in_order(:start_date, :end_date)
  end

  def special_event_dates_are_in_order
    date_fields_are_in_order(:special_event_start_date, :special_event_end_date)
  end

  def date_fields_are_in_order(start_field, end_field)
    start_val = send(start_field)
    end_val = send(end_field)
    return unless end_val && start_val

    errors.add(end_field, 'should be after start date') unless end_val >= start_val
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
