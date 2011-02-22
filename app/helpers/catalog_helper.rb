module CatalogHelper
  def self.compute_position(map_size, lat, lng)
    map_lats = [ 37.74995654795525, 37.767763359972506 ]
    map_lngs = [ -122.42721, -122.40425181274414 ] 

    latrange = map_lats[1] - map_lats[0]
    lngrange = map_lngs[1] - map_lngs[0]
    xrange = map_size[1]
    yrange = map_size[0]
    
    [ xrange.to_f * ((lat - map_lats[0])/latrange) ,
      yrange.to_f * ((lng - map_lngs[0])/lngrange) ]
  end
end
