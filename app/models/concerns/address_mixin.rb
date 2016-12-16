module AddressMixin
  # for models with street, city, zip, lat, lng and either state or addr_state

  def has_address?
    address.present? && address.geocoded?
  end

  def address
    Address.new(self)
  end

  def full_address
    address.to_s(true)
  end

  def map_link
    "http://maps.google.com/maps?q=%s" % URI.escape(self.full_address) if self.full_address
  end

  protected
  def get_state
    (self.respond_to? :addr_state) ? self.addr_state : self.state
  end

  def compute_geocode(force = false)
    begin
      if address.present? && (should_recompute? || force)
        result = Geokit::Geocoders::MultiGeocoder.geocode(address.to_s(true))
        if result.try(:success)
          self.lat = result.lat
          self.lng = result.lng
          [self.lat, self.lng]
        else
          #errors.add(:street, "Unable to Geocode your address.")
        end
      else
        # puts "No Adddress - skip geocoding"
      end
    rescue Exception => ex
    end
  end

  def should_recompute?
    (self.changes.keys & ["street", "city", "addr_state", "zip"]).present?
  end

end
