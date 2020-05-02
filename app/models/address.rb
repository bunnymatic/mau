# frozen_string_literal: true

class Address
  attr_reader :lat, :lng, :street, :city, :state, :zipcode

  def initialize(model)
    model = with_studio?(model) ? model.studio : model

    @lat = model.lat
    @lng = model.lng
    @street = model.street
    @city = fetch_with_default('San Francisco') { model.city }
    @state = fetch_with_default('CA') { get_state(model) }
    @zipcode = fetch_with_default('94110') { model.zipcode }
  rescue NoMethodError
    raise ArgumentError, 'the model does not appear to have address like attributes'
  end

  delegate :present?, to: :street

  def empty?
    street.blank?
  end

  def geocoded?
    lat.present? && lng.present?
  end

  def to_s(full = nil)
    return '' if empty?

    full ? [street, city, state, zipcode].join(', ') : [street, zipcode].join(' ')
  end

  def ==(other)
    (other.class == self.class) && (other._state == _state)
  end

  protected

  def _state
    [lat, lng, street, state, zipcode]
  end

  private

  def with_studio?(model)
    model.respond_to?(:studio_id) && model.studio
  end

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
