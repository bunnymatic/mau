# frozen_string_literal: true

class NewArtPiecePresenter
  attr_reader :artist, :art_piece, :studio, :open_studios

  def initialize(art_piece)
    @art_piece = ArtPiecePresenter.new(art_piece)
    @artist = @art_piece.artist
    @studio = StudioPresenter.new(@artist.studio || IndependentStudio.new)
    @open_studios = OpenStudiosEventPresenter.new(OpenStudiosEvent.current) if OpenStudiosEvent.current
  end

  def open_studios_info
    return if after_current_os?

    "See more at #{studio_address} during Open Studios #{open_studios.date_range}"
  end

  def hash_tags
    tags.uniq.map { |t| tag_cleaner(t) }.uniq.join(' ').gsub(/\s+/, ' ')
  end

  private

  def tags
    (
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
    @studio.indy? ? @artist.address : @studio.name
  end

  def tags_from_tags
    art_piece.tags.map { |tag| tag.name.downcase }
  end

  def tags_from_medium
    @art_piece.medium.present? ? [@art_piece.medium.name.downcase] : []
  end

  def tags_for_open_studios
    return [] unless artist.doing_open_studios?
    return [] if after_current_os?

    if art_span_os?
      ['SFOS', "SFOS#{current_os_start.year}", 'SFopenstudios']
    else
      %w[missionopenstudios springopenstudios]
    end
  end

  def custom_tags
    (SitePreferences.instance(true).social_media_tags || '').split(/,|\s/).select(&:present?)
  end

  def base_tags
    %w[#missionartists #sfart]
  end

  def after_current_os?
    current_os? && Time.current > current_os_end
  end

  def art_span_os?
    # time is after june and before current open studios
    current_os? && Time.current.month >= 6
  end

  def current_os?
    @open_studios.present?
  end

  def current_os_end
    current_os? && Time.zone.parse(@open_studios.end_date + ' 18:00:00')
  end

  def current_os_start
    current_os? && Time.zone.parse(@open_studios.start_date)
  end
end
