module MauImage
  class Paperclip
    STANDARD_STYLES = {
      small: '200x200#',
      medium: '400x400#',
      large: '800x800>',
    }.freeze

    # same as above but in a format that `variant` wants
    VARIANT_RESIZE_ARGUMENTS = {
      small: { resize_to_fill: [200, 200, { crop: :centre }] },
      medium: { resize_to_fill: [400, 400, { crop: :centre }] },
      large: { resize_to_fit: [800, 800] },
      original: {},
    }.freeze
  end
end
