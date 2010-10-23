class SetOrderFromRepresentativeArtPiece < ActiveRecord::Migration
  def self.up
    reps = Artist.find(:all, :conditions => ['representative_art_piece is not null']).map{|r| r.representative_art_piece}
    if reps.length > 0
      reps.each do |r|
        aps = ArtPiece.find(:all, :conditions => [ 'id in (?)', reps ])
        aps.each do |a| 
          a.order = 1
          a.save
        end
      end
    end
  end

  def self.down
  end
end
