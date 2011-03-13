module AddressMixin
  # for models with street, city, zip, lat, lng and either state or addr_state
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
    { :geocoded => !(self.lat.nil? || self.lng.nil?),
      :full => self.full_address,
      :simple => self.address,
      :latlng => [ self.lat, self.lng ],
      :parsed => {
        :street => self.street,
        :city => self.city,
        :state => get_state,
        :zip => self.zip,
        :lat => self.lat, 
        :lng => self.lng 
      }
        
    }
  end    

  protected
  def get_state
    (self.respond_to? :addr_state) ? self.addr_state : self.state
  end
end
