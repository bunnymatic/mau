require 'csv'

class SocialCatalogPresenter < ArtistsPresenter
  SOCIAL_KEYS = User.stored_attributes[:links].freeze

  def initialize
    super(os_only: true)
  end

  def artists
    super.select(&:art?).sort do |aa, bb|
      bb.representative_piece.updated_at <=> aa.representative_piece.updated_at
    end
  end

  def csv
    @csv ||=
      CSV.generate(**DEFAULT_CSV_OPTS) do |csv|
        csv << csv_headers
        artists.each do |artist|
          csv << artist_as_csv_row(artist)
        end
      end
  end

  def csv_filename
    @csv_filename ||= "#{['mau_social_artists', current_open_studios&.key].compact.join('_')}.csv"
  end

  def current_open_studios
    @current_open_studios ||= OpenStudiosEventPresenter.new(OpenStudiosEventService.current)
  end

  def date_range
    return '' unless current_open_studios.available? && artists.present?

    current_open_studios.date_range(separator: ' & ') + ", #{current_open_studios.year}"
  end

  private

  def csv_headers
    @csv_headers ||= (['Studio', 'Name', 'Art URL', 'Art Title', 'Medium', 'Tags', 'MAU Link', 'Email'] +
                    SOCIAL_KEYS.map { |s| s.to_s.humanize.capitalize }).freeze
  end

  def artist_as_csv_row(artist)
    [
      artist.studio.try(:name),
      artist.name,
      artist.representative_piece_url,
      artist.representative_piece_title,
      artist.representative_piece_medium,
      artist.representative_piece_tags.join(', '),
      artist_url(artist),
      artist.email,
    ] + SOCIAL_KEYS.map { |s| (artist.respond_to?(s) && artist.send(s)).to_s }
  end
end
