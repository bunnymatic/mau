require 'fastercsv'
class CatalogController < ApplicationController
  include MarkdownUtils
  layout 'catalog'

  def index

    @catalog = CatalogPresenter.new

    respond_to do |format|
      format.html # index.html.erb
      format.csv {
        render_csv :filename => 'mau_os_artists_%s' % (Conf.oslive.to_s || '') do |csv|
          csv << ["First Name","Last Name","Full Name","Email", "Group Site Name",
                  "Studio Address","Studio Number","Cross Street 1","Cross Street 2","Primary Medium"]
          [@indy_artists, @group_studio_artists.values].flatten.sort(&Artist::SORT_BY_LASTNAME).each do |artist|
            csv << [ artist.firstname, artist.lastname, artist.get_name, artist.email,
                     artist.studio ? artist.studio.name : '', artist.address_hash[:parsed][:street],
                     artist.studionumber, '', '', artist.primary_medium ? artist.primary_medium.name : '' ]
          end
        end
      }
    end
  end

  def social
    artists = fetch_social_artists
    respond_to do |format|
      format.html { render_error :message => 'Dunno what you were looking for.' }
      format.mobile { redirect_to root_path }
      format.csv {
        render_csv :filename => 'mau_social_artists_%s' % (Conf.oslive.to_s || '') do |csv|
          csv_keys = [:fullname, :email]  + social_keys
          csv << csv_keys.map{|s| s.to_s.humanize.capitalize}
          social_artists.sort(&Artist::SORT_BY_LASTNAME).each do |artist|
            csv << csv_keys.map{|s| artist.send s}
          end
        end
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
