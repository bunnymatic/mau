require 'uri'
class Studio < ActiveRecord::Base

  include AddressMixin

  has_many :artists

  acts_as_mappable
  before_validation_on_create :compute_geocode
  before_validation_on_update :compute_geocode
  before_save :normalize_phone_number

  cattr_reader :sort_by_name
  @@sort_by_name = lambda{|a,b| 
      if !a || a.id == 0
        1
      elsif !b || b.id == 0
        -1
      else
        a.name.downcase.gsub(/^the /,'') <=> b.name.downcase.gsub(/^the /,'')
      end
    }

  def normalize_phone_number
    if phone
      phone.gsub!(/\D+/,'')
    end
  end

  # return faux indy studio
  def self.indy
    s = Studio.new
    s.id = 0
    s.name = 'Independent Studios'
    s.street = "The Mission District"
    s.city = "San Francisco"
    s.state = "CA"
    s.artists = Artist.active.find(:all, :conditions => ["studio_id = 0 or studio_id is NULL"])
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
      artists = s.artists.active.all
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

  def get_name encode
    self.name
  end

  def formatted_phone
    phone.gsub(/(\d{3})(\d{3})(\d{4})/,"(\\1) \\2-\\3")
  end

end
