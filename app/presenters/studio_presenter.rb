class StudioPresenter

  attr_reader :studio
  delegate :name, :phone, :formatted_phone, :map_link, :city, :street, :url, :to => :studio

  def initialize(view_context, studio)
    @studio = studio
    @view_context = view_context
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
