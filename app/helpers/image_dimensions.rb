module ImageDimensions
  def get_scaled_dimensions(maxdim)
    # given maxdim, return width and height such that the max of width
    # or height = maxdim, and the other is scaled to the right aspect
    # ratio
    if self.image_height > 0 and self.image_width > 0
      ratio = self.image_width.to_f / self.image_height.to_f
      if ratio > 1.0
        [ maxdim, (maxdim / ratio).to_i ]
      else
        [ (maxdim * ratio).to_i, maxdim ]
      end
    else
      # can't compute it because we don't have a valid image height
      [maxdim, maxdim]
    end
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
