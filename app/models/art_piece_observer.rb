class ArtPieceObserver < ActiveRecord::Observer
  observe :art_piece
  def before_destroy(art)
    paths = art.get_paths.values
    paths.each do |pth|
      pth = File.expand_path( File.join( Rails.root, 'public', pth ) )
      if File.exist? pth
        begin
          result = File.delete pth
          RAILS_DEFAULT_LOGGER.debug("Deleted %s" % pth)
        rescue
          RAILS_DEFAULT_LOGGER.error("Failed to delete image %s [%s]" % [pth, $!])
        end
      end
    end
  end
  
  def after_save(art)
    # delete old art that is more than allowed
    artist = art.artist
    # mostly this makes stuff work for testing
    if artist
      max = artist.max_pieces
      cur = artist.art_pieces.length
      del = 0
      while cur > max
        artist.art_pieces.first.destroy
        cur = cur - 1
        del = del + 1
      end
    end
  end
end
