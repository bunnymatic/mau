# frozen_string_literal: true

require 'csv'

class AdminArtistList < ViewPresenter
  def good_standing_artists
    artists.active.order(updated_at: :desc)
  end

  def pending_artists
    artists.pending.order(updated_at: :desc)
  end

  def bad_standing_artists
    artists.bad_standing.order(updated_at: :desc)
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
          artists.all.each do |artist|
            csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def csv_filename
    'mau_artists.csv'
  end

  private

  def artists
    Artist.includes(:artist_info, :studio, :art_pieces)
  end

  def artist_as_csv_row(artist)
    [
      csv_safe(artist.login),
      csv_safe(artist.firstname),
      csv_safe(artist.lastname),
      artist.get_name,
      artist.studio&.name || '',
      artist.address&.street || '',
      artist.studionumber,
      artist.email,
    ]
  end
end
