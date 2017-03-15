# frozen_string_literal: true
class OpenStudiosEvent < ApplicationRecord
  # attr_accessible :end_date, :start_date, :key, :logo, :title

  validates :key, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_is_after_start_date

  has_attached_file :logo, styles: { square: '240x240#' }, default_url: ''
  validates_attachment_presence :logo
  validates_attachment_content_type :logo, content_type: %r{\Aimage\/.*\Z}

  def for_display(reverse = false)
    if !reverse
      start_date.strftime('%Y %b')
    else
      start_date.strftime('%b %-d-') + end_date.strftime('%-d %Y')
    end
  end

  # define future/past not as scopes because we want Time.zone.now() to be evaluated at query time
  # Also, this allows us to test with Timecop as opposed to using database NOW() method
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
