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
#  lat           :float
#  lng           :float
#  cross_street  :string(255)
#  phone         :string(255)
#  slug          :string(255)
#  image_width   :integer          default(0)
#  image_height  :integer          default(0)
#
# Indexes
#
#  index_studios_on_slug  (slug) UNIQUE
#

require 'uri'
class Studio < ActiveRecord::Base

  include AddressMixin
  include Geokit::ActsAsMappable

  extend FriendlyId
  friendly_id :name, use: :slugged

  has_many :artists

  acts_as_mappable
  before_validation(on: :create) { compute_geocode }
  before_validation(on: :update) { compute_geocode }
  before_save :normalize_phone_number
  validates :name, presence: true, uniqueness: true

  SORT_BY_NAME = lambda{|a,b|
      if !a || a.id == 0
        1
      elsif !b || b.id == 0
        -1
      else
        a.name.downcase.gsub(/^the /,'') <=> b.name.downcase.gsub(/^the /,'')
      end
    }

  def to_param
    slug || id
  end

  def normalize_phone_number
    if phone
      phone.gsub!(/\D+/,'')
    end
  end

  # return faux indy studio
  def self.indy
    IndependentStudio.new
  end

  def get_profile_image(size)
    StudioImage.get_path(self, size)
  end

end
