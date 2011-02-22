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
        key = a.studio.name + " " + a.studio.street
      else
        key = "Indy " + a.street
      end
      if not hsh[key]
        hsh[ key ] = []
      end
      hsh[key] << a
    end
        
    respond_to do |format|
      format.html # index.html.erb
      format.json  { render :json => 'this' }
      #format.pdf { render :pdf => 'this' }
    end
  end
end
