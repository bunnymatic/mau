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

    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true)
    # init icon
    @map.icon_global_init( GIcon.new(:image => '/images/icon/map_icon.png', 
                                     :iconSize => GSize.new(64.0, 64.0)),
                           'icon_name')
    markers = []

    @lat_lngs.each do |ll|
        m = GMarker.new(ll)
        markers << m
        @map.overlay_init(m)
    end
    sw = Artist::BOUNDS['SW']
    ne = Artist::BOUNDS['NE']
    @map.center_zoom_on_bounds_init([sw,ne])

    render :layout => 'catalog'
  end

end
