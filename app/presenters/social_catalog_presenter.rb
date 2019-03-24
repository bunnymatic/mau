# frozen_string_literal: true

require 'csv'

class SocialCatalogPresenter < ArtistsPresenter
  include OpenStudiosEventShim

  SOCIAL_KEYS = User.stored_attributes[:links].freeze

  def initialize
    super(true)
  end

  def artists
    super.select(&:art?).sort do |aa, bb|
      bb.representative_piece.updated_at <=> aa.representative_piece.updated_at
    end
  end

  def artist_has_links(artist)
    SOCIAL_KEYS.map { |s| artist.send(s).present? }.any?
  end

  def artist_has_image(artist)
    artist.representative_image.present?
  end

  def csv
    @csv ||=
      begin
        CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv << csv_headers
          artists.each do |artist|
            csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def csv_filename
    @csv_filename ||= (['mau_social_artists', current_open_studios_key].compact.join('_') + '.csv')
  end

  def os
    @os ||= OpenStudiosEventPresenter.new(OpenStudiosEvent.current)
  end

  private

  def artists_by_studio
    @artists_by_studio ||=
      begin
      artists = {}
      group_studio_artists.each do |a|
        artists[a.studio] = [] unless artists[a.studio]
        artists[a.studio] << a
      end
      artists.each_value do |artist_list|
        artist_list.sort!(&Artist::SORT_BY_LASTNAME)
      end
      artists
    end
  end

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
