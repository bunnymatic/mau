module AddressMixin
  # for models with street, city, zip, lat, lng and either state or addr_state
  def has_address?
    address.present? && address_hash[:geocoded]
  end

  def full_address
    # good for maps
    state = get_state
    if self.street && !self.street.empty?
      "%s, %s, %s, %s" % [self.street, self.city || "San Francisco", state || "CA", self.zip || "94110"]
    else
      ""
    end
  end

  def address
    if self.street && ! self.street.empty?
      return "%s %s" % [self.street, self.zip ]
    else
      ""
    end
  end

  def map_link
    "http://maps.google.com/maps?q=%s" % URI.escape(self.full_address)
  end

  def address_hash
    Hashie::Mash.new({ :geocoded => (lat.present? && lng.present?),
      :full => full_address,
      :simple => address,
      :latlng => [ lat, lng ],
      :parsed => {
        :street => street,
        :city => city,
        :state => get_state,
        :zip => zip,
        :lat => lat,
        :lng => lng
      }
    })
  end

  protected
  def get_state
    (self.respond_to? :addr_state) ? self.addr_state : self.state
  end

  def compute_geocode
    if has_address?
      result = Geokit::Geocoders::MultiGeocoder.geocode(full_address)
      if result.try(:success)
        self.lat, self.lng = result.lat, result.lng
      else
        #errors.add(:street, "Unable to Geocode your address.")
      end
    else
      puts "No Adddress - skip geocoding"
    end
  end

end
