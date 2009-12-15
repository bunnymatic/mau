class ArtistProfileImage
  def self.get_path(artist, size="medium")
    # get path for image of size
    # size should be either "thumb","medium"
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
