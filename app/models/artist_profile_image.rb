class ArtistProfileImage < ProfileImage

  DEFAULT_PROFILE_IMAGES = {
    "medium" => '/images/s_default-profile-img-not-me.png',
    "small" => '/images/s_default-profile-img-not-me.png',
    "thumb" => '/images/t_default-profile-img-not-me.png'
  }

  def self.get_path(artist, size="medium")
    # get path for image of size
    # size should be either "thumb","medium"
    if !artist || artist.profile_image.nil?
      return DEFAULT_PROFILE_IMAGES[size.to_s]
    end
    dir = "/artistdata/" + artist.id.to_s() + "/profile/"
    fname = File.basename(artist.profile_image)
    ImageFile.get_path(dir, size.to_s, fname)
  end

end
