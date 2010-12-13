require 'uri'
class Studio < ActiveRecord::Base

  include AddressMixin

  has_many :artists

  acts_as_mappable
  before_validation_on_create :compute_geocode
  before_validation_on_update :compute_geocode

  # return faux indy studio
  def self.indy
    s = Studio.new
    s.id = 0
    s.name = 'Independent Studios'
    s.street = "The Mission District"
    s.city = "San Francisco"
    s.state = "CA"
    s.artists = Artist.find(:all, :conditions => ["studio_id = 0 or studio_id is NULL and ( state = 'active' )"])
    s.profile_image = "independent-studios.jpg"
    s.image_height = 1
    s.image_width = 1
    s
  end

  def self.all
    logger.debug("Studio: Fetching from db")
    studios = super(:order => 'name')
    studios << Studio.indy 
    studios.each do |s|
      artists = s.artists.find(:all, :conditions => 'state = "active"')
      s[:num_artists] = artists.length
    end
    studios
  end

  def has_profile_image
    self.profile_image
  end

  def get_profile_image(size)
    StudioImage.get_path(self, size)
  end

  protected
  def compute_geocode
    result = Geokit::Geocoders::MultiGeocoder.geocode("%s, %s, %s, %s" % [self.street, self.city, self.state, self.zip])
    errors.add(:street, "Unable to Geocode the studio address.") if !result.success
    self.lat, self.lng = result.lat, result.lng if result.success
  end

end
