class ArtistInfo < ActiveRecord::Base
  belongs_to :artist

  acts_as_mappable
  before_validation_on_create :compute_geocode
  before_validation_on_update :compute_geocode

  include AddressMixin

  @@CACHE_KEY = 'ap_rep'

  def os_participation
    if self.open_studios_participation.blank? || !Conf.oslive
      {}
    else 
      parse_open_studios_participation(self.open_studios_participation)
    end
  end

  def update_os_participation(key,value)
    self.os_participation = Hash[key,value]
  end

  def os_participation=(os)
    current = parse_open_studios_participation(self.open_studios_participation)
    current.merge!(os)
    current.delete_if{ |k,v| !(v=='true' || v==true || v=='on' || v=='1' || v==1) }
    self.open_studios_participation = current.keys.join('|')
  end

  def representative_piece
    cache_key = "%s%s" % [@@CACHE_KEY, self.id]
    piece = Rails.cache.read(cache_key)
    if piece.nil?
      piece = self.artist.art_pieces.first
      Rails.cache.write(cache_key, piece)
    end
    return piece
  end

  def representative_pieces(n=1)
    ap = self.artist.art_pieces[0..n-1]
  end

  protected
    def compute_geocode
      # use artist's address
      result = Geokit::Geocoders::MultiGeocoder.geocode("%s, %s, %s, %s" % [self.street, self.city || "San Francisco", self.addr_state || "CA", self.zip || "94110"])
      errors.add(:street, "Unable to Geocode your address.") if !result.success
      self.lat, self.lng = result.lat, result.lng if result.success
    end

  private 
  def parse_open_studios_participation(os)
    if os.blank?
      {}
    else
      Hash[ os.split('|').select{|k| k.match(/^[\w\d]/)}.map{ |k| [k,true] }]
    end
  end

end
