class ArtistProfileImage
  DEFAULT_PROFILE_IMAGES = {
    "medium" => '/images/s_default-profile-img-not-me.png',
    "small" => '/images/s_default-profile-img-not-me.png',
    "thumb" => '/images/t_default-profile-img-not-me.png'
  }

  def self.get_path(artist, size="medium")
    # get path for image of size
    # size should be either "thumb","medium"
    if !artist || artist.profile_image.nil?
      return DEFAULT_PROFILE_IMAGES[size]
    end
    dir = "/artistdata/" + artist.id.to_s() + "/profile/"
    fname = File.basename(artist.profile_image)
    ImageFile.get_path(dir, size, fname)
  end

  def self.save(upload, artist)
    upload = upload['datafile']
    name = upload.original_filename
    dir = "artistdata/" + artist.id.to_s() + "/profile"
    # get extension from filename
    ext = ""
    lastdot = name.rindex(".")
    ext = name[lastdot..-1] if lastdot
    newfname = "profile" + ext
    saved, ht, wd = ImageFile.save(upload, dir, destfile=newfname)
    artist.profile_image = saved
    artist.image_height = ht
    artist.image_width = wd
    artist.save
  end
end
