# frozen_string_literal: true
class Address
  attr_reader :lat, :lng, :street, :city, :state, :zip

  def initialize(model)
    begin
      if model.respond_to?(:studio_id) && (model.studio_id.presence.to_i > 0) && model.studio
        model = model.studio
      end

      @lat = model.lat
      @lng = model.lng
      @street = model.street
      @city = fetch_with_default("San Francisco") { model.city }
      @state = fetch_with_default("CA") { get_state(model) }
      @zip = fetch_with_default("94110") { model.zip }

    rescue NoMethodError => ex
      raise ArgumentError.new("the model does not appear to have address like attributes")
    end
  end

  def present?
    !street.blank?
  end

  def empty?
    !present?
  end

  def geocoded?
    lat.present? && lng.present?
  end

  def to_s(full = nil)
    return "" unless present?
    full ? [street, city, state, zip].join(", ") : [street, zip].join(" ")
  end

  def ==(addr)
    (addr.class == self.class) && (addr._state == self._state)
  end

  protected

  def _state
    [lat, lng, street, state, zip]
  end

  private

  def get_state(model)
    return model.addr_state if model.respond_to?(:addr_state)
    model.state
  end

  def fetch_with_default(default)
    val = yield
    return default if val.blank?
    val
  end
end
