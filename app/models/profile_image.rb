class ProfileImage

  # save a profile image given an uploaded file and
  # the object to save it on (Artist or Studio)
  def self.save(upload, object)
    upload = upload['datafile']
    name = upload.original_filename
    dir = %W|public #{object.class.name.downcase}data #{object.id.to_s} profile|.join("/")
    # get extension from filename
    newfname = "profile#{File.extname(name)}"

    saved, ht, wd = ImageFile.save(upload, dir, destfile=newfname)
    object.profile_image = saved
    object.image_height = ht
    object.image_width = wd
    object.save
  end
end
