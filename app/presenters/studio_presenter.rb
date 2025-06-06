class StudioPresenter < ViewPresenter
  attr_reader :studio

  delegate :slug,
           :phone,
           :map_link,
           :address,
           :city,
           :street,
           :cross_street,
           :url,
           :url?,
           :to_param,
           to: :studio

  def initialize(studio)
    super()
    @studio = studio
  end

  def name
    studio.try(:name)
  end

  def search_name
    (name || '').downcase
  end

  def phone?
    phone.present?
  end

  def formatted_phone
    phone.gsub(/(\d{3})(\d{3})(\d{4})/, '(\\1) \\2-\\3')
  end

  def page_title
    @page_title ||= PageInfoService.title("Studio: #{name}")
  end

  delegate :profile_image?, to: :studio

  def image(size = 'small')
    studio.profile_image(size) || '/images/default-studio.png'
  end

  def street_with_cross
    [studio.street, ("(@ #{studio.cross_street})" if studio.cross_street?)].compact.join(' ')
  end

  def artists_count_label
    @artists_count_label ||=
      artists? ? "#{artists.count} artist".pluralize(artists.count) : ''
  end

  def open_studios_artists_count_label
    return @open_studios_artists_count_label unless @open_studios_artists_count_label.nil?

    @open_studios_artists_count_label = ''
    if open_studios_artists? && current_open_studios
      @open_studios_artists_count_label = "#{open_studios_artists.count} artist".pluralize(open_studios_artists.count) +
                                          " in #{current_open_studios.title}"
    end
    @open_studios_artists_count_label
  end

  def open_studios_artists
    return Artist.none if OpenStudiosEventService.current.blank?

    OpenStudiosEventService.current.artists.where(studio:)
  end

  def artists_with_art?
    artists_with_art.present?
  end

  def artists_with_art
    @artists_with_art ||=
      artists.joins(:art_pieces).map { |artist| ArtistPresenter.new(artist) }
  end

  def artists?
    artists.count.positive?
  end

  def open_studios_artists?
    open_studios_artists.count.positive?
  end

  def artists_without_art?
    artists_without_art.present?
  end

  def artists_without_art
    @artists_without_art ||= artists.select { |a| a.art_pieces.empty? }
  end

  def artists
    @artists ||= @studio.artists.active.includes(:artist_info, :art_pieces, :open_studios_events)
  end

  def indy?
    @studio.id.zero?
  end

  def website
    url.gsub('http://', '')
  end

  def studio_path
    url_helpers.studio_path(@studio)
  end

  def current_open_studios
    @current_open_studios ||= OpenStudiosEventService.current
  end
end
