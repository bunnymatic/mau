# == Schema Information
#
# Table name: open_studios_events
#
#  id                :integer          not null, primary key
#  start_date        :datetime
#  end_date          :datetime
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  key               :string(255)
#  logo_file_name    :string(255)
#  logo_content_type :string(255)
#  logo_file_size    :integer
#  logo_updated_at   :datetime
#  title             :string(255)      default("Open Studios"), not null
#

class OpenStudiosEvent < ActiveRecord::Base
  attr_accessible :end_date, :start_date, :key, :logo, :title

  validates :key, presence: true, uniqueness: true
  validates :start_date, presence: true
  validates :end_date, presence: true
  validate :end_date_is_after_start_date

  has_attached_file :logo, styles: { square: "240x240#" }
  validates_attachment_presence :logo
  validates_attachment_content_type :logo, content_type: /\Aimage\/.*\Z/

  def pretty_print(reverse = false)
    start_date.strftime( reverse ? "%B %Y" : "%Y %B" )
  end

  # define future/past not as scopes because we want Time.zone.now() to be evaluated at query time
  # Also, this allows us to test with Timecop as opposed to using database NOW() method
  def self.past
    where("start_date < ?", Time.zone.now()).order(:start_date)
  end

  def self.future
    where("end_date > ?", Time.zone.now()).order(:start_date)
  end

  def self.current
    future.first
  end

  def self.current_key
    current.try(:key)
  end

  def self.pretty_print(os_key = nil, reverse = false )
    if !os_key && current
      current.pretty_print
    elsif os_key
      os_key = os_key.to_s
      yr = os_key[0..3]
      mo = os_key[4..-1]
      seas = (mo == '10') ? 'Oct':'Apr'
      "%s %s" % (reverse ? [seas,yr] : [ yr, seas ])
    else
      'n/a'
    end
  end

  def end_date_is_after_start_date
    if end_date && start_date
      errors.add(:end_date, 'should be after start date.') unless end_date >= start_date
    end
  end

end
