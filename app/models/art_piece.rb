class ArtPiece < ActiveRecord::Base
  belongs_to :artist
  has_many :art_pieces_tags
  has_many :tags, :through => :art_pieces_tags

  validates_presence_of     :title
  validates_length_of       :title,    :within => 2..80
  
  def medium
    if self.medium_id && self.medium_id > 0
      Medium.find(self.medium_id)
    end
  end

  def get_paths()
    ArtPieceImage.get_paths(self)
  end

  def get_scaled_dimensions(maxdim)
    # given maxdim, return width and height such that the max of width
    # or height = maxdim, and the other is scaled to the right aspect
    # ratio
    if self.image_height != 0 and self.image_width != 0
      ratio = self.image_width.to_f / self.image_height.to_f
      if ratio > 1.0
        [ maxdim, (maxdim / ratio).to_i ]
      else
        [ (maxdim * ratio).to_i, maxdim ]
      end
    else
      # can't compute it because we don't have a valid image height
      [maxdim, maxdim]
    end
  end

  def get_path(size="medium")
    ArtPieceImage.get_path(self, size)
  end
    
  def self.all
    self.find(:all, :conditions => "artist_id in (select id from artists where state = 'active')")
  end

end
