require 'csv'

class AdminArtistList

  include Enumerable

  ALLOWED_SORT_BY = ['studio_id','lastname','firstname','id','login','email', 'activated_at'].freeze

  def initialize(view_context, sort_by, reverse)
    @view_context = view_context
    set_sort_by(sort_by)
    @reverse = reverse
  end

  def reverse_sort_links
    allowed_sort_by.map do |key|
      @view_context.link_to key, base_path(:rsort_by => key)
    end
  end

  def sort_links
    allowed_sort_by.map do |key|
      @view_context.link_to key, base_path(:sort_by => key)
    end
  end

  def artists
    @artists ||=
      begin
        artists = Artist.all(:order => sort_by_clause, :include => [:artist_info, :studio])
      end
  end

  def csv_headers
    @csv_headers ||= ["Login", "First Name","Last Name","Full Name","Group Site Name",
                      "Studio Address","Studio Number","Email Address"]
  end

  def csv
    @csv ||=
      begin
        csv_data = CSV.generate(ApplicationController::DEFAULT_CSV_OPTS) do |_csv|
          _csv << csv_headers
          artists.each do |artist|
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
     artist.csv_safe(:login),
     artist.csv_safe(:firstname),
     artist.csv_safe(:lastname),
     artist.get_name,
     artist.studio ? artist.studio.name : '',
     (artist.address_hash.parsed.street if artist.has_address?),
     artist.studionumber,
     artist.email
    ]
  end

  def base_path(opts)
    @view_context.admin_artists_path(opts)
  end


end
