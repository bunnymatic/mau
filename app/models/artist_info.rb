class ArtistInfo < ActiveRecord::Base
  belongs_to :artist

  def representative_piece
    pc = self.representative_pieces
    if pc and pc.length 
      return pc[0]
    end
    nil
  end

  def representative_pieces(n=1)
    aps = []
    if self.representative_art_piece && self.representative_art_piece > 0
      begin
        p "Putting #{self.representative_art_piece} at the top"
        rep = ArtPiece.find(self.representative_art_piece)
        aps << rep
      rescue ActiveRecord::RecordNotFound
        rep = nil
      end
    end
    ap = self.artist.art_pieces
    if !ap.empty?
      # move rep to top if necessary
      len = ap.length
      num = [n, len].min
      if !rep
        return ap[0..num-1]
      else
        ap[0..num-1].each do |a| 
          if a.id != rep.id
            aps << a
          end
        end
      end
      return aps[0..num-1]
    end
    nil
  end
end
