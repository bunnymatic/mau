class StudioPresenter

  include OsHelper

  attr_reader :studio, :is_mobile
  delegate :phone, :formatted_phone, :map_link, :city, :street, :url, :to => :studio

  def initialize(view_context, studio, is_mobile = false)
    @studio = studio
    @view_context = view_context
    @is_mobile = is_mobile
  end

  def name
    studio.try(:name)
  end

  def mobile_title
    @mobile_title ||= "Studio: #{name}" if name
  end

  def fullsite_title
    @fullsite_title ||= "Mission Artists United - Studio: %s" if name
  end

  def page_title
    @page_title ||= (is_mobile) ? mobile_title : fullsite_title
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
    if @studio.cross_street.present?
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
        if has_open_studios_artists?
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
      artists.select{|a| a.art_pieces.present?}.map{|artist| ArtistPresenter.new(@view_context, artist)}
    @artists_with_art
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

  def display_url
    @studio.url.gsub('http://','')
  end

  def studio_path
    @view_context.studio_path(@studio)
  end

end
