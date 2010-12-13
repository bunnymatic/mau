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
    end
  end

  def map_link
    state = get_state

    "http://maps.google.com/maps?q=%s,%s,%s %s" % [ self.street,
                                                    self.city,
                                                    state,
                                                    self.zip.to_s ].map { |a| URI.escape(a) }
  end
  
  def address_hash
    {:full => self.full_address,
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
    (self.respond_to? :state) ? self.state : self.addr_state
  end
end
