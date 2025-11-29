class NewArtPiecePresenter
  attr_reader :artist, :art_piece, :studio, :current_open_studios

  def initialize(art_piece)
    @art_piece = ArtPiecePresenter.new(art_piece)
    @artist = @art_piece.artist
    @studio = StudioPresenter.new(@artist.studio || IndependentStudio.new)
    @current_open_studios = OpenStudiosEventPresenter.new(OpenStudiosEventService.current) if OpenStudiosEventService.current
  end

  def open_studios_info
    return unless include_os_info?

    "See more at #{studio_address} during Open Studios #{current_open_studios.date_range}"
  end

  def hash_tags
    tags.uniq.map { |t| tag_cleaner(t) }.uniq.join(' ').gsub(/\s+/, ' ')
  end

  private

  def tags
    (
      tags_from_artist_social_media +
      custom_tags +
      tags_from_tags +
      tags_from_medium +
      tags_for_open_studios +
      base_tags
    )
  end

  def tag_cleaner(tag)
    return tag if tag.starts_with?('@')

    "##{tag.gsub(/\W/, '')}"
  end

  def studio_address
    studio.indy? ? artist.address : studio.name
  end

  def tags_from_tags
    art_piece.tags.map { |tag| tag.name.downcase }
  end

  def tags_from_medium
    art_piece.medium.present? ? [art_piece.medium.name.downcase] : []
  end

  def tags_for_open_studios
    return [] unless include_os_info?

    if art_span_os?
      ['SFOS', "SFOS#{current_os_start.year}", 'SFopenstudios']
    else
      %w[missionopenstudios springopenstudios]
    end
  end

  def tags_from_artist_social_media
    return [] if artist.instagram.blank?

    handle = SocialLinkHelper.new(artist.instagram).handle
    [
      (if handle.present?
         handle.starts_with?('@') ? handle : "@#{handle}"
       end),
    ].compact_blank
  end

  def custom_tags
    (SitePreferences.instance(check_cache: true).social_media_tags || '').split(/,|\s/).compact_blank
  end

  def base_tags
    %w[#missionartists #sfart]
  end

  def include_os_info?
    current_os? && !after_current_os? && artist.doing_open_studios?
  end

  def after_current_os?
    current_os? && Time.current > current_os_end
  end

  def art_span_os?
    # time is after june and before current open studios
    current_os? && Time.current.month >= 6
  end

  def current_os?
    current_open_studios.present? && current_open_studios.promote?
  end

  def current_os_end
    current_os? && Time.zone.parse("#{current_open_studios.end_date} 18:00:00")
  end

  def current_os_start
    current_os? && Time.zone.parse(current_open_studios.start_date)
  end
end
