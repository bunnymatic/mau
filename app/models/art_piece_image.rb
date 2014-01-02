class ArtPieceImageError < StandardError; end

class ArtPieceImage < ImageFile

  MISSING_ART_PIECE = '/images/missing_artpiece.gif'

  delegate :artist, :filename, :to => :art_piece

  attr_accessor :art_piece

  def initialize(art_piece, upload)
    @art_piece = art_piece
    dir = File.join("public", image_dir)
    super upload, dir
  end

  def valid?
    @valid ||= ((art_piece.is_a? ArtPiece) || art_piece.filename.blank? || !artist)
  end

  def image_dir 
    @image_dir ||= "/artistdata/#{artist.id}/imgs/"
  end


  def self.get_paths(art_piece)
    Hash[ImageSizes.all.keys.map do |kk|
           path = self.get_path(art_piece, kk.to_s)
           [kk, path]
         end
        ]
  end

  def self.get_path(piece, size="medium")
    return MISSING_ART_PIECE if !piece || !piece.is_a?(ArtPiece) || !piece.artist || piece.filename.blank?

    fname = File.basename(piece.filename)
    path = "/artistdata/#{piece.artist.id}/imgs/"
    ImageFile.get_path(path, size, fname)
  end

  def save
    return if !artist
    info = super
    # save data to the artpiece
    # fname for html is same as dir without leading "public"
    art_piece.filename = info.path
    art_piece.image_height = info.height
    art_piece.image_width = info.width
    art_piece.save ? info.path : ""
  end
end
