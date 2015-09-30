class StudioImage < ProfileImage

  # def self.get_path(studio, size="medium")
  #   if studio.photo?
  #     return studio.photo(size)
  #   end
  #   # get path for image of size
  #   # size should be either "thumb","small", or "medium"
  #   dir = "/studiodata/" + studio.id.to_s() + "/profile/"
  #   if studio.profile_image?
  #     fname = File.basename(studio.profile_image)
  #     ImageFile.get_path(dir, size, fname)
  #   else
  #     # return default image
  #     ImageFile.get_path("/images/", size, "default-studio.png")
  #   end
  # end

end
