# frozen_string_literal: true

module AddressMixin
  # for models with street, city, zipcode, lat, lng and either state or addr_state

  def address?
    address.present? && address.geocoded?
  end

  def address
    Address.new(self)
  end

  def full_address
    address.to_s(true)
  end

  def map_link
    sprintf('http://maps.google.com/maps?q=%s', CGI.escape(full_address)) if full_address
  end

  protected

  def get_state
    respond_to?(:addr_state) ? addr_state : state
  end

  def compute_geocode(force = false)
    return unless (should_recompute? || force) && address.present?

    begin
      if address.present? && (should_recompute? || force)
        result = Geokit::Geocoders::MultiGeocoder.geocode(address.to_s(true))
        if result.try(:success)
          self.lat = result.lat
          self.lng = result.lng
          [lat, lng]
        end
      end
    rescue Geocoder::Error
      logger.warn("Failed to Geocode: #{address.to_s(true)} for #{inspect}")
    end
  end

  def should_recompute?
    (changes.keys & %w[street city addr_state zipcode]).present?
  end
end
