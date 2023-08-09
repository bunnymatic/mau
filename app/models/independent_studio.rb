class IndependentStudio
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  include ActiveModel::Serialization

  include AddressMixin

  attr_reader :studio

  delegate :id, :name, :street, :city, :state, :cross_street, :phone, :zipcode, :lat, :lng, to: :studio

  class InnerStudio < Struct.new(:id,
                                 :name,
                                 :street,
                                 :city,
                                 :state,
                                 :cross_street,
                                 :phone,
                                 :zipcode,
                                 :profile_image,
                                 :lat,
                                 :lng)
    def initialize(attrs)
      super(*attrs.values_at(:id,
                             :name,
                             :street,
                             :city,
                             :state,
                             :cross_street,
                             :phone,
                             :zipcode,
                             :profile_image,
                             :lat,
                             :lng))
    end

    def to_param
      name.parameterize
    end
  end

  class ImageContainer
    def initialize(img)
      @img = img
    end

    def url(*_args)
      @img
    end

    def to_json(*_args)
      url
    end
  end

  def initialize(*_args)
    # stick this in @studio so that to_json structures things just like Studio#to_json
    @studio = InnerStudio.new(id: 0,
                              name: 'Independent Studios',
                              street: 'The Mission District',
                              city: 'San Francisco',
                              state: 'CA',
                              zipcode: '94110',
                              profile_image: ImageContainer.new('/studiodata/0/profile/independent-studios.jpg'),
                              cross_street: nil,
                              phone: nil,
                              lat: nil,
                              lng: nil)
  end

  def slug
    to_param
  end

  def artists
    @artists ||= Artist.active.where(studio_id: nil)
  end

  def cross_street?
    false
  end

  def phone?
    false
  end

  def url?
    false
  end

  def url
    nil
  end

  def profile_image(*_args)
    @studio.profile_image.url
  end

  def persisted?
    true
  end

  def touch
    true
  end

  def save
    true
  end

  def save!
    self
  end

  def map_link
    'http://maps.google.com/?q=SF+CA,+94110'
  end

  def profile_image?
    true
  end
end
