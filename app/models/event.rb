# == Schema Information
#
# Table name: events
#
#  id                  :integer          not null, primary key
#  title               :string(255)
#  description         :text
#  tweet               :string(255)
#  street              :string(255)
#  venue               :string(255)
#  state               :string(255)
#  city                :string(255)
#  zip                 :string(255)
#  starttime           :datetime
#  endtime             :datetime
#  url                 :string(255)
#  lat                 :float
#  lng                 :float
#  user_id             :integer
#  publish             :datetime
#  reception_starttime :datetime
#  reception_endtime   :datetime
#

require 'event_calendar'
class Event < ActiveRecord::Base
  include EventCalendar
  include AddressMixin

  has_event_calendar :start_at_field => :reception_starttime, :end_at_field => :reception_endtime
  acts_as_mappable

  #after_validation(:on => :create) { compute_geocode }
  #after_validation(:on => :update) { compute_geocode }

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :venue
  validates_presence_of :street
  validates_presence_of :city
  validates_presence_of :starttime

  validate :validate_endtime
  validate :validate_reception_time

  scope :future, where('((starttime > NOW()) or (reception_starttime > NOW()))')
  scope :past, where('(endtime is not null and endtime < NOW())')
  scope :not_past, where('not(endtime is not null and endtime < NOW())')
  scope :published, where('publish is not null')

  default_scope order('starttime')

  belongs_to :user

  include AddressMixin

  def self.keyed_by_month
    by_month = {}

    all.each do |ev|
      key = ev.month_year_key
      by_month[key] ||= {:display => ev.display_month, :events => [] }
      by_month[key][:events] << ev
    end
    by_month
  end

  def name
    title
  end

  def month_year_key
    @month_year_key ||= stime.strftime('%Y%m')
  end

  def display_month
    @display_month ||= stime.strftime('%B %Y')
  end

  def validate_endtime
    if !endtime
      return
    else
      errors.add(:endtime, 'should be after start time.') unless endtime >= starttime
    end
  end

  def valid_reception_time?
    reception_endtime >= reception_starttime
  end

  def validate_reception_time
    if reception_starttime && reception_endtime
      errors.add(:reception_endtime, 'should be after reception start time.') unless valid_reception_time?
    end
  end

  def published?
    !!publish
  end

  def in_progress?
    endtime && endtime > Time.zone.now && starttime < Time.zone.now
  end

  def past?
    r = starttime < Time.zone.now
    if endtime
      r = r && (endtime < Time.zone.now)
    end
    r
  end

  def future?
    (reception_starttime && reception_starttime > Time.zone.now ) || (starttime > Time.zone.now)
  end

  # get start time or reception start time
  def stime
    @stime ||= (reception_starttime || starttime)
  end

end
