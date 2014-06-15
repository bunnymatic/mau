# == Schema Information
#
# Table name: open_studios_events
#
#  id         :integer          not null, primary key
#  start_date :datetime
#  end_date   :datetime
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class OpenStudiosEvent < ActiveRecord::Base
  attr_accessible :end_date, :start_date

  validates :start_date, :presence => true
  validates :end_date, :presence => true
  validate :end_date_is_after_start_date

  scope :past, where("start_date < NOW()")
  scope :future, where("start_date > NOW()")

  def self.current
    future.order(:start_date).first
  end

  def self.current_key
    current.try(:key)
  end

  def key
    "%04d%02d" % [start_date.year, start_date.month]
  end

  def end_date_is_after_start_date
    errors.add(:end_date, 'should be after start date.') unless end_date >= start_date
  end

end
