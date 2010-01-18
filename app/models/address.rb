class Address
  attr_accessor :title, :geocode

  @@KEY = 'geo'
  def initialize(title, street, state="CA", zip="94110")
    @title = title
    k = '%s%s%s%s' % [ @@KEY, street, state, zip]
    k.gsub!(' ','')
    k.gsub!('_','')
    gc = nil
    begin
      gc = CACHE.get(k)
    rescue
    end
    if not gc
      result = Geocoding::get("%s, %s, %s" % [street, state, zip])
      if result.status == Geocoding::GEO_SUCCESS
        gc = result[0]
        begin
          CACHE.set(k, gc)
        rescue
        end
      end
    end
    @geocode = gc
  end
  
  def coord
    @geocode.latlon
  end
end
