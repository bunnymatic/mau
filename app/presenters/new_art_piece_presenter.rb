# frozen_string_literal: true

class NewArtPiecePresenter
  attr_reader :artist, :art_piece, :studio, :open_studios

  def initialize(art_piece)
    @art_piece = ArtPiecePresenter.new(art_piece)
    @artist = @art_piece.artist
    @studio = StudioPresenter.new(@artist.studio || IndependentStudio.new)
    @open_studios = OpenStudiosEventPresenter.new(OpenStudiosEvent.current)
  end

  def open_studios_info
    return unless before_current_os?
    "See more at #{studio_address} during Open Studios #{open_studios.date_range}"
  end

  def hash_tags
    (
      hash_tags_from_tags +
      hash_tags_from_medium +
      hash_tags_from_open_studios +
      base_hash_tags
    ).uniq.join(' ')
  end

  private

  def studio_address
    @studio.indy? ? @artist.address : @studio.name
  end

  def hash_tags_from_tags
    art_piece.tags.map { |tag| "##{tag.name}" }
  end

  def hash_tags_from_medium
    @art_piece.medium.present? ? ["##{art_piece.medium.name}"] : []
  end

  def hash_tags_from_open_studios
    return [] unless artist.doing_open_studios?
    return [] unless before_current_os?
    if art_span_os?
      ['#SFOS', "#SFOS#{current_os_start.year}", '#SFopenstudios']
    else
      ['#missionopenstudios', '#springopenstudios']
    end
  end

  def base_hash_tags
    ['#missionartists', '@sfmau']
  end

  def before_current_os?
    Time.current < current_os_start
  end

  def art_span_os?
    # time is after june and before current open studios
    Time.current.month >= 6
  end

  def current_os_start
    Time.zone.parse(@open_studios.start_date)
  end
end
