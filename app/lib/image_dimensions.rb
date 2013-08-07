module ImageDimensions

  def compute_dimensions
    dims = ImageFile::ImageSizes.all.keys.inject({}) do |r,k|

      key= ImageFile::ImageSizes.keymap(k)
      sz = ImageFile::ImageSizes.all[key]
      if !sz
        r[k] = [0,0]
      elsif k == :original
        r[k] = [image_width.to_i, image_height.to_i]
      else
        maxdim = [sz.width, sz.height].max
        wd = ht = 0

        if image_width.to_i > 0 and image_height.to_i> 0
          rt = image_height.to_f / image_width.to_f
          if rt < 1.0
            wd = maxdim.to_i
            ht = (wd * rt).to_i
          else
            ht = maxdim.to_i
            wd = (ht / rt).to_i
          end
        end
        r[k] = [wd,ht]
      end
      r
    end
    Hashie::Mash.new(dims)
  end

  def get_min_scaled_dimensions(mindim)
    # given maxdim, return width and height such that the max of width
    # or height = mindim, and the other is scaled to the right aspect
    # ratio
    if self.image_height > 0 and self.image_width > 0
      ratio = self.image_width.to_f / self.image_height.to_f
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
end
