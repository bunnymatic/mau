require 'uri'
require 'artist'
class Studio < ActiveRecord::Base

  include AddressMixin

  has_many :artists

  acts_as_mappable
  before_validation :compute_geocode
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

  def to_json opts = {}
    super({:except => [:created_at, :updated_at]}.merge(opts))
  end

  # return faux indy studio
  def self.indy
    s = Studio.where(:id => 0).first
    if !s
      s = Studio.new
      s.id = 0
      s.name = 'Independent Studios'
      s.street = "The Mission District"
      s.city = "San Francisco"
      s.state = "CA"
      s.artists = Artist.active.where(["studio_id = 0 or studio_id is NULL"])
      s.profile_image = "independent-studios.jpg"
      s.image_height = 1
      s.image_width = 1
    end
    s
  end

  def self.all
    super.order('name') << Studio.indy
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
