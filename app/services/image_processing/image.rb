module ImageProcessing
  class Image
    def initialize(vips_image)
      @vips_image = vips_image
    end

    def _vips_image
      @vips_image
    end

    def aspect_ratio
      @vips_image.width / @vips_image.height
    end

    def orientation
      aspect_ratio < 1.0 ? :portrait : :landscape
    end

    def dimensions
      { width:, height: }
    end

    delegate :width, to: :@vips_image

    delegate :height, to: :@vips_image

    ## Vips::Image passthroughs

    def resize(...)
      self.class.new(@vips_image.resize(...))
    end

    def composite(overlay, mode, **)
      # puts @vips_image, "VIPS IMAGE"
      # debugger
      self.class.new(@vips_image.composite2(overlay._vips_image, mode, **))
    end

    def write_to_file(...)
      @vips_image.write_to_file(...)
    end
  end
end
