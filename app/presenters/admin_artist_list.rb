# frozen_string_literal: true

require 'csv'

class AdminArtistList < ViewPresenter
  include Enumerable

  def raw_artists
    @raw_artists ||= Artist.all.includes(:artist_info, :studio, :art_pieces)
  end

  def artists
    @artists ||=
      begin
        raw_artists.map { |a| ArtistPresenter.new(a) }
      end
  end

  def csv_headers
    @csv_headers ||= ['Login', 'First Name', 'Last Name', 'Full Name', 'Group Site Name',
                      'Studio Address', 'Studio Number', 'Email Address']
  end

  def csv
    @csv ||=
      begin
        CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv << csv_headers
          raw_artists.each do |artist|
            csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def csv_filename
    'mau_artists.csv'
  end

  def each(&block)
    artists.each(&block)
  end

  private

  def artist_as_csv_row(artist)
    [
      csv_safe(artist.login),
      csv_safe(artist.firstname),
      csv_safe(artist.lastname),
      artist.get_name,
      artist.studio ? artist.studio.name : '',
      artist.address.street,
      artist.studionumber,
      artist.email
    ]
  end
end
