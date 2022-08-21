class StudioImage < ProfileImage
  def self.paths(studio)
    @paths ||= MauImage::ImageSize.allowed_sizes.to_h do |kk|
      path = studio.profile_image(kk.to_s)
      [kk, path]
    end
  end
end
