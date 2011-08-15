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

  named_scope :future, :conditions => ['starttime > NOW()' ]
  named_scope :past, :conditions => ['starttime < NOW()' ]
  named_scope :published, :conditions => ['publish is not null']

  include AddressMixin

  def validate_endtime
    errors.add(:endtime, 'should be after start time.') unless ((endtime >= starttime) && endtime.present?)
  end

  protected
    def compute_geocode
      # use artist's address
      result = Geokit::Geocoders::MultiGeocoder.geocode("%s, %s, %s, %s" % [self.street, self.city || "San Francisco", self.state || "CA", self.zip || "94110"])
      errors.add(:street, "Unable to Geocode your address.") if !result.success
      self.lat, self.lng = result.lat, result.lng if result.success
    end
  
end
