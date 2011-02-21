class TestsController < ApplicationController
  # GET /studios
  # GET /studios.xml
  before_filter :admin_required
  layout 'mau1col'

  def custom_map
    @map_size = [ 596, 591 ]
    
    map_lats = [ 37.75008654795525, 37.767763359972506 ]
    map_lngs = [ -122.42721, -122.40455181274414 ] 

    num_pts = 10
    
    @lat_lngs = []
    lat_range = map_lats[1] - map_lats[0]
    lng_range = map_lngs[1] - map_lngs[0]
    lat = map_lats[0]
    (0..10).each do |row|
      lng = map_lngs[0]
      (0..10).each do |col|
        @lat_lngs << [lat, lng]
        lng += lng_range * 0.1
      end
      lat += lat_range * 0.1
    end
    render :layout => 'catalog'
  end

end
