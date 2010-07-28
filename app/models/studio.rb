require 'uri'

class Studio < ActiveRecord::Base
  @@CACHE_EXPIRY =  (Conf.cache_expiry[:objects] or 0)
  @@STUDIOS_KEY = (Conf.cache_ns or '') + 'studios'

  has_many :artists

  before_save :compute_geocode
  before_update :compute_geocode

  after_save :flush_cache
  after_update :flush_cache
  after_destroy :flush_cache

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
    begin
      studios = CACHE.get(@@STUDIOS_KEY)
    rescue
      logger.warn("Studio: Memcache seems to be dead")
      studios = nil
    end
    if ! studios
      logger.debug("Studio: Fetching from db")
      studios = super(:order => 'name')
      studios << Studio.indy 
      studios.each do |s|
        artists = s.artists.find(:all, :conditions => 'state = "active"')
        s[:num_artists] = artists.length
      end
      begin
        CACHE.set(@@STUDIOS_KEY, studios, @@CACHE_EXPIRY)
        print "put studio info in cache"
      rescue
        logger.warn("Studio: Failed to set artists in cache")
      end
    else
      logger.debug("Studio: fetch from cache")
    end
    studios
  end

  def map_link
    "http://maps.google.com/maps?q=%s,%s,%s %s" % [ self.street,
                                                    self.city,
                                                    self.state,
                                                    self.zip.to_s ].map { |a| URI.escape(a) }
  end


  def has_profile_image
    self.profile_image
  end

  def get_profile_image(size)
    StudioImage.get_path(self, size)
  end

  protected
  def compute_geocode
    # use artist's address
    result = Geocoding::get("%s, %s, %s, %s" % [self.street, self.city, self.state, self.zip])
    if result.status == Geocoding::GEO_SUCCESS
      self.lat, self.lng = result[0].latitude, result[0].longitude
    end
  end

  def flush_cache
    Studio.flush_cache
  end

  def self.flush_cache
    logger.debug "Studio: Flushing cache"
    begin
      CACHE.delete(@@STUDIOS_KEY)
    rescue
      logger.warn("Studio: Memcache delete failed")
    end
  end

end
