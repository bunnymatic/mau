require 'csv'

class AdminArtistList
  ALLOWED_SORT_BY = ['studio_id','lastname','firstname','id','login','email', 'activated_at'].freeze

  def initialize(sort_by, reverse)
    set_sort_by(sort_by)
    @reverse = reverse
  end

  def set_sort_by(sort_by)
    @sort_by = (ALLOWED_SORT_BY.include? sort_by.to_s) ? sort_by : ALLOWED_SORT_BY.first
  end

  def artists
    @artists ||= 
      begin
        artists = Artist.all(:order => sort_by_clause, :include => :artist_info)
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

  private
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
     artist.address_hash[:parsed][:street],
     artist.studionumber,
     artist.email 
    ]
  end

end
