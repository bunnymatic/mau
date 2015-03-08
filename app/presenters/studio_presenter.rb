class StudioPresenter

  include OpenStudiosEventShim

  attr_reader :studio
  delegate :phone, :phone?, :map_link, :city, :street, :cross_street, :url, :url?, :to => :studio

  def initialize(view_context, studio)
    @studio = studio
    @view_context = view_context
  end

  def name
    studio.try(:name)
  end

  def search_name
    (name || '').downcase
  end

  def has_phone?
    phone.present?
  end

  def formatted_phone
    phone.gsub(/(\d{3})(\d{3})(\d{4})/,"(\\1) \\2-\\3")
  end

  def page_title
    @page_title ||= "Mission Artists United - Studio: %s" if name
  end

  def image(size = 'small')
    if @studio.profile_image?
      @studio.get_profile_image(size)
    else
      "/images/default-studio.png"
    end
  end

  def street_with_cross
    r = @studio.street
    if @studio.cross_street?
      r << " (@ #{studio.cross_street})"
    end
    r
  end

  def artists_count_label
    @artists_count_label ||=
      has_artists? ? "#{artists.count} artist".pluralize(artists.count) : ''
  end

  def open_studios_artists_count_label
    @open_studios_count_label ||=
      begin
        current_open_studios = OpenStudiosEvent.current
        if has_open_studios_artists? && current_open_studios
          "#{open_studios_artists.count} artist".pluralize(open_studios_artists.count) + " in #{current_open_studios.title}"
        else
          ''
        end
      end
  end

  def open_studios_artists
    artists.open_studios_participants
  end

  def has_artists_with_art?
    artists_with_art.present?
  end

  def artists_with_art
    @artists_with_art ||=
      begin
        artists.select{|a| a.art_pieces.present?}.map{|artist| ArtistPresenter.new(artist)}
      end
  end

  def has_artists?
    @has_artists ||= (artists.count > 0)
  end

  def has_open_studios_artists?
    @has_open_studios_artists ||= (open_studios_artists.count > 0)
  end

  def has_artists_without_art?
    artists_without_art.present?
  end

  def artists_without_art
    @artists_without_art ||= artists.select{|a| a.art_pieces.empty?}
  end

  def with_active_artists?
    artists.present?
  end

  def artists
    @artists ||= @studio.artists.active
  end

  def indy?
    @studio.id == 0
  end

  def website
    url.gsub('http://','')
  end

  def studio_path
    @view_context.studio_path(@studio)
  end

end
