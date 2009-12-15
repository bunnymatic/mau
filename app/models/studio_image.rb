class StudioImage
  def self.get_path(studio, size="medium")
    # get path for image of size
    # size should be either "thumb","small", or "medium"
    dir = "/studiodata/" + studio.id.to_s() + "/profile/"
    if studio.has_profile_image
      fname = File.basename(studio.profile_image)
      ImageFile.get_path(dir, size, fname)
    else
      # return default image
      ImageFile.get_path("/images/", size, "default-studio.png")
    end
  end

  def self.save(upload, studio)
    upload = upload['datafile']
    name = upload.original_filename
    dir = "studiodata/" + studio.id.to_s() + "/profile"
    # get extension from filename
    ext = ""
    lastdot = name.rindex(".")
    ext = name[lastdot..-1] if lastdot
    newfname = "profile" + ext
    saved, ht, wd = ImageFile.save(upload, dir, destfile=newfname)
    studio.profile_image = saved
    studio.image_height = ht
    studio.image_width = wd
    studio.save
  end
end
