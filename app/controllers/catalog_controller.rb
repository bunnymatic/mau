require 'csv'
class CatalogController < ApplicationController
  include MarkdownUtils
  layout 'catalog'

  def index

    @catalog = CatalogPresenter.new

    respond_to do |format|
      format.html # index.html.erb
      format.csv {
        csv_data = CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv << ["First Name","Last Name","Full Name","Email", "Group Site Name",
                  "Studio Address","Studio Number","Cross Street 1","Cross Street 2","Primary Medium"]
          @catalog.all_artists.sort(&Artist::SORT_BY_LASTNAME).each do |artist|
            csv << [ artist.firstname, artist.lastname, artist.get_name, artist.email,
                     artist.studio ? artist.studio.name : '', artist.address_hash[:parsed][:street],
                     artist.studionumber, '', '', artist.primary_medium ? artist.primary_medium.name : '' ]
          end
        end
        render_csv_string(csv_data.to_s, 'mau_os_artists_%s' % (Conf.oslive.to_s || ''))
      }
    end
  end

  def social
    artists = fetch_social_artists
    respond_to do |format|
      format.html { render_error :message => 'Dunno what you were looking for.' }
      format.mobile { redirect_to root_path }
      format.csv {
        csv_data = CSV.generate(DEFAULT_CSV_OPTS) do |csv|
          csv_keys = [:full_name, :email]  + SOCIAL_KEYS
          csv << csv_keys.map{|s| s.to_s.humanize.capitalize}
          artists.sort(&Artist::SORT_BY_LASTNAME).each do |artist|
            csv << csv_keys.map{|s| artist.send s}
          end
        end
        render_csv_string(csv_data.to_s,'mau_social_artists_%s' % (Conf.oslive.to_s || ''))
      }
    end
  end

  SOCIAL_KEYS = [:facebook, :flickr, :twitter, :blog, :myspace]

  def fetch_social_artists
    Artist.active.open_studios_participants.select do |a|
      SOCIAL_KEYS.map{|s| a.send(s).present?}.any?
    end
  end

end
