class StudioPresenter

  attr_reader :studio, :is_mobile
  delegate :name, :phone, :formatted_phone, :map_link, :city, :street, :url, :to => :studio

  def initialize(view_context, studio, is_mobile = false)
    @studio = studio
    @view_context = view_context
    @is_mobile = is_mobile
  end

  def mobile_title
    @mobile_title ||= "Studio: #{studio.name}"
  end
  
  def fullsite_title
    @fullsite_title ||= "Mission Artists United - Studio: %s" % studio.name
  end

  def page_title
    @page_title ||= (is_mobile) ? mobile_title : fullsite_title
  end

  def image
    if @studio.profile_image?
      @studio.get_profile_image('small')
    else
      "/images/default-studio.png"
    end
  end

  def street_with_cross
    r = @studio.street
    if @studio.cross_street.present?
      r << " (@ #{studio.cross_street})"
    end
    r
  end

  def open_studios_artists
    artists.open_studios_participants
  end

  def has_artists_with_art?
    artists_with_art.present?
  end

  def artists_with_art
    @artists_with_art ||= artists.select{|a| a.art_pieces.present?}
  end

  def has_artists_without_art?
    artists_without_art.present?
  end

  def artists_without_art
    @artists_without_art ||= artists.select{|a| a.art_pieces.empty?}
  end

  def artists
    @artists ||= @studio.artists.active
  end

  def indy?
    @studio.id == 0
  end

  def display_url
    @studio.url.gsub('http://','')
  end

end
