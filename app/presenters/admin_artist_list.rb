# frozen_string_literal: true
require 'csv'

class AdminArtistList < ViewPresenter
  include Enumerable

  ALLOWED_SORT_BY = %w(studio_id lastname firstname id login email activated_at).freeze

  def raw_artists
    @raw_artists ||= Artist.all.includes(:artist_info, :studio, :art_pieces).order(sort_by_clause)
  end

  def artists
    @artists ||=
      begin
        raw_artists.map{|a| ArtistPresenter.new(a) }
      end
  end

  def csv_headers
    @csv_headers ||= ["Login", "First Name","Last Name","Full Name","Group Site Name",
                      "Studio Address","Studio Number","Email Address"]
  end

  def csv
    @csv ||=
      begin
        csv_data = CSV.generate(DEFAULT_CSV_OPTS) do |_csv|
          _csv << csv_headers
          raw_artists.each do |artist|
            _csv << artist_as_csv_row(artist)
          end
        end
      end
  end

  def csv_filename
    'mau_artists.csv'
  end

  def allowed_sort_by
    ALLOWED_SORT_BY
  end

  def each(&block)
    artists.each(&block)
  end

  private

  def set_sort_by(sort_by)
    @sort_by = (ALLOWED_SORT_BY.include? sort_by.to_s) ? sort_by : ALLOWED_SORT_BY.first
  end

  def sort_by_clause
    "#{@sort_by} #{@reverse ? 'DESC' : 'ASC'}" if @sort_by.present?
  end

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
