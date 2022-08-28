class StudioImage < ProfileImage
  def self.images(studio)
    @images ||= MauImage::ImageSize.allowed_sizes.to_h do |kk|
      path = studio.profile_image(kk.to_s)
      [kk, path]
    end
  end
end
