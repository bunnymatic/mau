require 'htmlhelper'
class Event < ActiveRecord::Base
  
  acts_as_mappable

  after_validation_on_create :compute_geocode
  after_validation_on_update :compute_geocode

  validates_presence_of :title
  validates_presence_of :description
  validates_presence_of :venue
  validates_presence_of :street
  validates_presence_of :city
  validates_presence_of :starttime

  validate :validate_endtime
  validate :validate_reception_time

  named_scope :future, :conditions => ['(endtime is not null and endtime > NOW()) or (starttime > NOW())' ]
  named_scope :past, :conditions => ['(endtime is not null and endtime < NOW()) or (starttime < NOW())' ]
  named_scope :published, :conditions => ['publish is not null']

  default_scope :order => 'starttime'

  belongs_to :user

  include AddressMixin

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
    endtime && endtime > Time.now && starttime < Time.now
  end

  def past?
    r = starttime < Time.now
    if endtime
      r = r && (endtime < Time.now)
    end
    r
  end

  def future?
    starttime > Time.now
  end

  protected
    def compute_geocode
      # use artist's address
      result = Geokit::Geocoders::MultiGeocoder.geocode("%s, %s, %s, %s" % [self.street, self.city || "San Francisco", self.state || "CA", self.zip || "94110"])
      errors.add(:street, "Unable to Geocode your address.") if !result.success
      self.lat, self.lng = result.lat, result.lng if result.success
    end
  
end
