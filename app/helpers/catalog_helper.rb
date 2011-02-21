module CatalogHelper
  def self.compute_position(map_size, lat, lng)
    map_lats = [ 37.75032407630291, 37.76762766157575 ]
    map_lngs = [ -122.426586614379, -122.404232889]
    latrange = map_lats[1] - map_lats[0]
    lngrange = map_lngs[1] - map_lngs[0]
    xrange = map_size[0]
    yrange = map_size[1]
    
    [ xrange.to_f * ((lat - map_lats[0])/latrange) ,
      yrange.to_f * ((lng - map_lngs[0])/lngrange) ]
  end
end
