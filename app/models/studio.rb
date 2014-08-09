# == Schema Information
#
# Table name: studios
#
#  id            :integer          not null, primary key
#  name          :string(255)
#  street        :string(255)
#  city          :string(255)
#  state         :string(255)
#  zip           :integer
#  url           :string(255)
#  created_at    :datetime
#  updated_at    :datetime
#  profile_image :string(255)
#  image_height  :integer          default(0)
#  image_width   :integer          default(0)
#  lat           :float
#  lng           :float
#  cross_street  :string(255)
#  phone         :string(255)
#

require 'uri'
class Studio < ActiveRecord::Base

  include AddressMixin
  include Geokit::ActsAsMappable

  has_many :artists

  acts_as_mappable
  before_validation(:on => :create) { compute_geocode }
  before_validation(:on => :update) { compute_geocode }
  before_save :normalize_phone_number
  validates :name, :presence => true

  SORT_BY_NAME = lambda{|a,b|
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
    s = Studio.where(:name => "Indepedent Studios").first
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
    order('name').all << Studio.indy
  end

  def active_artists
    artists.active
  end

  def get_profile_image(size)
    StudioImage.get_path(self, size)
  end

  def formatted_phone
    phone.gsub(/(\d{3})(\d{3})(\d{4})/,"(\\1) \\2-\\3")
  end

end
