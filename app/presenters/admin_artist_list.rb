# frozen_string_literal: true

require 'csv'

class AdminArtistList < ViewPresenter
  include Enumerable

  def raw_artists
    Artist.includes(:artist_info, :studio, :art_pieces)
  end

  def good_standing_artists
    raw_artists.good_standing.map { |a| ArtistPresenter.new(a) }
  end

  def bad_standing_artists
    raw_artists.bad_standing.map { |a| ArtistPresenter.new(a) }
  end

  def artists
    @artists ||=
      begin
        raw_artists.all.map { |a| ArtistPresenter.new(a) }
      end
  end

  CSV_HEADERS = [
    'Login', 'First Name', 'Last Name', 'Full Name', 'Group Site Name',
    'Studio Address', 'Studio Number', 'Email Address'
  ].freeze

  def csv
    @csv ||=
      begin
        CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv << CSV_HEADERS
          raw_artists.all.each do |artist|
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
