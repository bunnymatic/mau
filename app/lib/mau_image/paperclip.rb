module MauImage
  class Paperclip
    STANDARD_STYLES = {
      small: '200x200#',
      medium: '400x400#',
      large: '800x800>',
    }.freeze

    # same as above but in a format that `variant` wants
    VARIANT_RESIZE_ARGUMENTS = {
      small: { resize_to_limit: [200, 200] },
      medium: { resize_to_limit: [400, 400] },
      large: { resize_to_limit: [800, 800] },
      original: {},
    }.freeze
  end
end
