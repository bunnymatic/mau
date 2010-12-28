class ArtPieceImage < ImageFile
  def self.get_paths(artpiece)
    pths = []
    self.sizes.map { |kk,vv| kk }.each do |nm|
      path = self.get_path(artpiece, nm.to_s)
      if path
        pths << path
      end
    end
    # add original
    path = self.get_path(artpiece, 'original')
    if path
      pths << path
    end
    pths
  end

  def self.get_path(artpiece, size="medium")
    # get path for image of size
    # size should be either "thumb","medium","original"
    if not artpiece
      return "/images/missing_artpiece.gif"
    end
    # should happen only if there has been data corruption
    begin
      owner = artpiece.artist
    rescue
      owner = nil
    end
    return if ! owner
    dir = "/artistdata/" + owner.id.to_s() + "/imgs/"
    if not artpiece.filename
      return ""
    end
    fname = File.basename(artpiece.filename)
    ImageFile.get_path(dir, size, fname)
  end

  def self.save(upload, artpiece)
    upload = upload['datafile']
    name = upload
    owner = artpiece.artist
    return if ! owner
    dir = "public/artistdata/" + owner.id.to_s() + "/imgs/"
    (saved, ht, wd) = ImageFile.save(upload, dir)
    # save data to the artpiece
    # fname for html is same as dir without leading "public"
    artpiece.filename = saved
    artpiece.image_height = ht
    artpiece.image_width = wd
    artpiece.save ? saved : ""
  end
end
