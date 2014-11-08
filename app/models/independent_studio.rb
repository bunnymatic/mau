class IndependentStudio
  extend  ActiveModel::Naming
  extend  ActiveModel::Translation
  include ActiveModel::Validations
  include ActiveModel::Conversion
  
  attr_reader :id, :name, :street, :city, :state, :image_height, :image_width, :cross_street, :phone, :zip

  class ImageContainer
    def initialize(img)
      @img = img
    end
    def url(*args)
      @img
    end
  end

  def initialize(*args)
    @id = 0
    @name = 'Independent Studios'
    @street = "The Mission District"
    @city = "San Francisco"
    @state = "CA"
    @zip = '94110'
    @profile_image = ImageContainer.new("independent-studios.jpg")
    @image_height = 1
    @image_width = 1
    @cross_street = nil
    @phone = nil
  end

  def artists
    @artists ||= Artist.active.where(["studio_id = 0 or studio_id is NULL"])
  end

  def url
    @profile_image.url
  end

  def get_profile_image(*args)
    @profile_image
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
