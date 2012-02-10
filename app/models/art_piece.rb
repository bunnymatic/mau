require 'htmlhelper'

class ArtPiece < ActiveRecord::Base
  include ImageDimensions

  belongs_to :artist
  has_many :art_pieces_tags
  has_many :art_piece_tags, :through => :art_pieces_tags

  after_save :clear_caches
  default_scope :order => '`order`'

  NEW_ART_CACHE_KEY = 'newart'
  NEW_ART_CACHE_EXPIRY = Conf.cache_expiry['new_art'].to_i

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
    klassname = self.class.name
    super
    # remove all tag entries from ArtPiecesTags
    ArtPiecesTag.delete_all ["art_piece_id = ? ", id]
    Favorite.delete_all ["favoritable_id = ? and favoritable_type = ?", id, klassname]
  end

  def get_paths()
    ArtPieceImage.get_paths(self)
  end

  def uniq_tags
    htags = {}
    self.art_piece_tags.each { |t| htags[t.name] = t }
    htags.values
  end

  def get_name(escape = false)
    escape ? safe_title : self.title
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

  def self.get_new_art
    cache_key = NEW_ART_CACHE_KEY
    new_art = Rails.cache.read(cache_key)
    unless new_art
      new_art = ArtPiece.find(:all, :conditions => ['artist_id is not null && artist_id > 0'], :limit => 12, :order => 'created_at desc')
      Rails.cache.write(cache_key, new_art, :expires_in => NEW_ART_CACHE_EXPIRY)
    end
    new_art || []
  end

  private
  def clear_caches
    cache_key = NEW_ART_CACHE_KEY 
    Rails.cache.delete(cache_key)

    if self.artist && self.artist.id != nil?
      Rails.cache.delete("%s%s" % [Artist::CACHE_KEY, self.artist.id])
    end
  end
end
