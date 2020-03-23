# frozen_string_literal: true

class OpenStudiosEvent < ApplicationRecord
  validates :key, presence: true, uniqueness: { case_sensitive: true }
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_is_after_start_date

  has_many :open_studios_participants, inverse_of: :open_studios_event, dependent: :destroy
  has_many :artists, through: :open_studios_participants, class_name: 'Artist', source: :user

  def for_display(reverse = false)
    if !reverse
      start_date.strftime('%Y %b')
    else
      date = start_date.strftime('%b %-d-')
      if start_date.month == end_date.month
        date + end_date.strftime('%-d %Y')
      else
        date + end_date.strftime('%b %-d %Y')
      end
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

  def end_date_is_after_start_date
    return unless end_date && start_date

    errors.add(:end_date, 'should be after start date.') unless end_date >= start_date
  end
end
