class ArtPieceImage < ImageFile

  MISSING_ART_PIECE = '/images/missing_artpiece.gif'

  def self.get_paths(artpiece)
    Hash[ImageSizes.all.keys.map do |kk|
           path = self.get_path(artpiece, kk.to_s)
           [kk, path]
         end
        ]
  end

  def self.get_path(artpiece, size="medium")
    # get path for image of size
    # size should be either "thumb","medium","original"
    unless artpiece.is_a? ArtPiece
      return MISSING_ART_PIECE
    end
    # should happen only if there has been data corruption
    begin
      owner = artpiece.artist
    rescue
      owner = nil
    end
    return MISSING_ART_PIECE if ! owner
    dir = "/artistdata/#{owner.id}/imgs/"
    if not artpiece.filename
      return MISSING_ART_PIECE
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
    info = ImageFile.save(upload, dir)
    # save data to the artpiece
    # fname for html is same as dir without leading "public"
    artpiece.filename = info.path
    artpiece.image_height = info.height
    artpiece.image_width = info.width
    artpiece.save ? info.path : ""
  end
end
