require 'htmlhelper'
require 'event_calendar'
class Event < ActiveRecord::Base
  include EventCalendar
  include AddressMixin

  has_event_calendar :start_at_field => :reception_starttime, :end_at_field => :reception_endtime
  acts_as_mappable

  after_validation(:on => :create) { compute_geocode }
  after_validation(:on => :update) { compute_geocode }

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

  def name
    title
  end
  
  def validate_endtime
    if !endtime
      return
    else
      errors.add(:endtime, 'should be after start time.') unless endtime >= starttime
    end
  end

  def validate_reception_time
    if reception_starttime && reception_endtime
      errors.add(:reception_endtime, 'should be after reception start time.') unless reception_endtime >= reception_starttime
    else
      return
    end
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

end
