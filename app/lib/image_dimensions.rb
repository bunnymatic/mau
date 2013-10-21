module ImageDimensions

  def compute_dimensions
    dims = ImageFile::ImageSizes.all.keys.inject({}) do |r,k|

      key= ImageFile::ImageSizes.keymap(k)
      sz = ImageFile::ImageSizes.all[key]
      if k == :original
        r[k] = [image_width.to_i, image_height.to_i]
      else
        maxdim = [sz.width, sz.height].max
        r[k] = get_max_scaled_dimensions maxdim
      end
      r
    end
    Hashie::Mash.new(dims)
  end

  def get_min_scaled_dimensions(mindim)
    # given mindim, return width and height such that the max of width
    # or height = mindim, and the other is scaled to the right aspect
    # ratio
    w, h = [image_width, image_height].map(&:to_i)
    if h > 0 and w > 0
      ratio = w.to_f / h.to_f
      if ratio < 1.0
        [ mindim, (mindim / ratio).to_i ]
      else
        [ (mindim * ratio).to_i, mindim ]
      end
    else
      # can't compute it because we don't have a valid image height
      [mindim, mindim]
    end
  end

  def get_max_scaled_dimensions(maxdim)
    # given maxdim, return the scaled version of size such that the
    # largest dimension fits in maxdim
    w, h = [image_width, image_height].map(&:to_i)
    if w > 0 && h > 0
      ratio = (h.to_f/w.to_f)
      if ratio < 1.0
        [maxdim, maxdim.to_i * ratio].map(&:to_i)
      else
        [maxdim.to_i / ratio, maxdim].map(&:to_i)
      end
    else
      [0,0]
    end
  end

end
