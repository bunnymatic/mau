class IndependentStudio
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  
  attr_reader :studio

  delegate :id, :name, :street, :city, :state, :image_height, :image_width, :cross_street, :phone, :zip, to: :studio

  class InnerStudio < Struct.new(:id, :name, :street, :city, :state, :image_height, :image_width, :cross_street, :phone, :zip, :profile_image)
    def initialize(h)
      super(*h.values_at(:id, :name, :street, :city, :state, :image_height, :image_width, :cross_street, :phone, :zip, :profile_image))
    end
  end

  class ImageContainer
    def initialize(img)
      @img = img
    end
    def url(*args)
      @img
    end
    def to_json
      url
    end
  end

  def initialize(*args)
    # stick this in @studio so that to_json structures things just like Studio#to_json
    @studio = InnerStudio.new({
                                id: 0,
                                name: 'Independent Studios',
                                street: "The Mission District",
                                city: "San Francisco",
                                state: "CA",
                                zip: '94110',
                                profile_image: ImageContainer.new("/studiodata/0/profile/independent-studios.jpg"),
                                image_height: 1,
                                image_width: 1,
                                cross_street: nil,
                                phone: nil
                              })
  end

  def artists
    @artists ||= Artist.active.where(["studio_id = 0 or studio_id is NULL"])
  end

  def cross_street?
    nil
  end

  def phone?
    nil
  end

  def url?
    false
  end

  def url
    nil
  end

  def get_profile_image(*args)
    @studio.profile_image.url
  end

  def persisted?
    true
  end

  def save
    true
  end

  def save!
    self
  end

  def map_link
    nil
  end

  def profile_image?
    true
  end
end
