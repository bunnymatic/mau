class ProfileImage

  # save a profile image given an uploaded file and
  # the object to save it on (Artist or Studio)
  def self.save(upload, object)
    upload = upload['datafile']
    name = upload.original_filename
    dir = File.join %W|public #{object.class.name.downcase}data #{object.id.to_s} profile|
    # get extension from filename
    newfname = "profile#{File.extname(name)}"

    info = ImageFile.save(upload, dir, newfname)
    object.profile_image = info.path
    object.image_height = info.height
    object.image_width = info.width
    object.save
  end
end
