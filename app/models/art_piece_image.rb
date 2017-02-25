# frozen_string_literal: true
class ArtPieceImageError < StandardError; end

class ArtPieceImage < ImageFile
  delegate :artist, :filename, to: :art_piece

  attr_accessor :art_piece

  def initialize(art_piece)
    @art_piece = art_piece
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
                      [kk, path] if path
                    end.reject{|_k,v| v.nil?}
                   ]
  end

  def path(size="medium")
    return art_piece.photo(size) if art_piece.photo?
    return unless filename && artist
    fname = File.basename(filename)
    path = artist_image_dir(artist)
    ImageFile.get_path(path, size, fname)
  end
end
