require 'fastercsv'
class CatalogController < ApplicationController
  layout 'catalog'
  def index
    @map_size = [ 596, 591 ]
    artists = Artist.active.open_studios_participants
    @os_artists = artists.each_with_object({}) do |a,hsh|
      if a.studio_id == 0 && !a.street
        next
      end
      if a.studio_id > 0
        key = a.studio.name + "__BREAK__" + a.studio.street
      else
        key = "Indy__BREAK__" + a.street
      end
      if not hsh[key]
        hsh[ key ] = []
      end
      hsh[key] << a
    end
        
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => 'this' }
      format.csv {
        render_csv :filename => 'mau_os_artists' do |csv|
          csv << ["First Name","Last Name","Full Name","Group Site Name","Studio Address","Studio Number","Cross Street 1","Cross Street 2","Primary Medium"]
          artists.sort{|a,b| a.lastname <=> b.lastname}.each do |artist|
            csv << [ artist.firstname, artist.lastname, artist.get_name, artist.studio ? artist.studio.name : '', artist.address_hash[:parsed][:street], artist.studionumber, '', '', artist.primary_medium ? artist.primary_medium.name : '' ]
          end
        end
      }
      #format.pdf { render :pdf => 'this' }
    end
  end

end
