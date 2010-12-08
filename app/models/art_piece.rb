require 'htmlhelper'

class ArtPiece < ActiveRecord::Base
  include ImageDimensions

  belongs_to :artist
  has_many :art_pieces_tags
  has_many :tags, :through => :art_pieces_tags

  validates_presence_of     :title
  validates_length_of       :title,    :within => 2..80

  def get_share_link(urlsafe=false)
    link = 'http://%s/art_pieces/%s' % [Conf.site_url, self.id]
    urlsafe ? CGI::escape(link): link
  end

  def medium
    if self.medium_id && self.medium_id > 0
      Medium.find(self.medium_id)
    end
  end

  def destroy
    id = self.id
    super
    # remove all tag entries from ArtPiecesTags
    ArtPiecesTag.delete_all ["art_piece_id = ? ", id]
  end

  def get_paths()
    ArtPieceImage.get_paths(self)
  end

  def uniq_tags
    htags = {}
    self.tags.each { |t| htags[t.name] = t }
    htags.values
  end

  def safe_title
    HTMLHelper.encode(self.title)
  end

  def get_path(size="medium")
    ArtPieceImage.get_path(self, size)
  end
    
  def self.all
    self.find(:all, :conditions => "artist_id in (select id from users where state = 'active' and type='Artist')")
  end

end
