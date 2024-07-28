# namespace for mau image related stuffs
module MauImage
  class InvalidVariantError < StandardError; end

  STANDARD_STYLES = {
    thumb: '150x150#',
    small: '200x200#',
    medium: '400x400#',
    large: '800x800>',
  }.freeze

  # same as above but in a format that `variant` wants
  VARIANT_RESIZE_ARGUMENTS = {
    thumb: { resize_to_fill: [150, 150, { crop: :centre }] },
    small: { resize_to_fill: [200, 200, { crop: :centre }] },
    medium: { resize_to_fill: [400, 400, { crop: :centre }] },
    large: { resize_to_fit: [800, 800] },
    original: {},
  }.freeze

  def self.variant_args(size)
    r = VARIANT_RESIZE_ARGUMENTS[size.to_sym]
    raise InvalidVariantError, "#{size} is not a valid image variant" unless r

    r
  end
end
