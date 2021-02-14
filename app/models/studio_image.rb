class StudioImage < ProfileImage
  def self.paths(studio)
    @paths ||= Hash[MauImage::ImageSize.allowed_sizes.map do |kk|
                      path = studio.get_profile_image(kk.to_s)
                      [kk, path]
                    end
                   ]
  end

  def self.get_path(studio, size = 'medium')
    return studio.photo(size) if studio.photo?

    # get path for image of size
    # size should be either "thumb","small", or "medium"
    dir = "/studiodata/#{studio.id}/profile/"
    if studio.profile_image?
      fname = File.basename(studio.profile_image)
      ImageFile.get_path(dir, size, fname)
    else
      # return default image
      ImageFile.get_path('/images/', size, 'default-studio.png')
    end
  end
end
