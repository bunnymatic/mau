class ArtPieceImageError < StandardError; end

class ArtPieceImage < ImageFile

  MISSING_ART_PIECE = '/images/missing_artpiece.gif'

  delegate :artist, :filename, :to => :art_piece

  attr_accessor :art_piece

  def initialize(art_piece)
    @art_piece = art_piece
  end

  def valid?
    @valid ||= (art_piece && (art_piece.is_a? ArtPiece) && artist && filename.present?)
  end

  def image_dir
    @image_dir ||= artist_image_dir(artist)
  end

  def artist_image_dir(artist)
    "/artistdata/#{artist.id}/imgs/"
  end

  def paths
    @paths ||= Hash[MauImage::ImageSize.allowed_sizes.map do |kk|
                      path = self.path kk.to_s
                      [kk, path]
                    end
                   ]
  end

  def path(size="medium")
    if art_piece.photo?
      return art_piece.photo(size)
    end

    return MISSING_ART_PIECE if !valid?

    fname = File.basename(filename)
    path = artist_image_dir(artist)
    ImageFile.get_path(path, size, fname)
  end

  def save(upload)
    # return if !artist
    # dest_dir = File.join("public", image_dir)
    # info = super upload, dest_dir
    # # save data to the artpiece
    # # fname for html is same as dir without leading "public"
    # art_piece.filename = info.path
    # art_piece.image_height = info.height
    # art_piece.image_width = info.width
    # art_piece.save ? info.path : ""
  end
end
