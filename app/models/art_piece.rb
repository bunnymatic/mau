# == Schema Information
#
# Table name: art_pieces
#
#  id           :integer          not null, primary key
#  filename     :string(255)
#  title        :string(255)
#  description  :text
#  dimensions   :string(255)
#  artist_id    :integer
#  created_at   :datetime
#  updated_at   :datetime
#  medium_id    :integer
#  year         :integer
#  image_height :integer          default(0)
#  image_width  :integer          default(0)
#  order        :integer
#
# Indexes
#
#  index_art_pieces_on_artist_id  (artist_id)
#  index_art_pieces_on_medium_id  (medium_id)
#

class ArtPiece < ActiveRecord::Base
  belongs_to :artist

  has_many :art_pieces_tags
  has_many :art_piece_tags, :through => :art_pieces_tags

  belongs_to :medium
  include ImageDimensions
  include ImageFileHelpers
  include HtmlHelper
  include TagsHelper

  before_destroy :remove_images
  after_destroy :clear_tags_and_favorites
  after_save :remove_old_art
  after_save :clear_caches
  #default_scope order('`order`')

  NEW_ART_CACHE_KEY = 'newart'
  NEW_ART_CACHE_EXPIRY = Conf.cache_expiry['new_art'].to_i

  validates_presence_of     :title
  validates_length_of       :title,    :within => 2..80

  def to_json(opts={})
    opts[:methods] ||= []
    opts[:except] ||= []
    if opts[:methods].is_a?(Array)
      opts[:methods] << :image_urls
    end
    if opts[:except].is_a?(Array)
      #opts[:except] << :filename
    end
    super opts
  end

  def image_urls
    Hash[ ArtPieceImage.get_paths(self).map{|k,v| [k, full_image_path(v)]} ]
  end

  def image_paths
    ArtPieceImage.get_paths(self)
  end

  alias :tags :art_piece_tags
  def get_share_link(urlsafe=false)
    link = 'http://%s/art_pieces/%s' % [Conf.site_url, self.id]
    urlsafe ? CGI::escape(link): link
  end

  def add_tag(tag_string)
    art_piece_tags << tags_from_s(tag_string)
  end

  def clear_tags_and_favorites
    klassname = self.class.name
    Favorite.where(:favoritable_id => id, :favoritable_type => klassname).compact.map(&:destroy)
  end

  def get_paths
    ArtPieceImage.get_paths(self)
  end

  def uniq_tags
    art_piece_tags.uniq_by(&:name)
  end

  def get_name(escape = false)
    escape ? safe_title : self.title
  end

  def safe_title
    html_encode(self.title)
  end

  def get_path(size = nil, full_path = false)
    size ||= 'medium'
    artpiece_path = ArtPieceImage.get_path(self, size)
    (full_path ? full_image_path(artpiece_path) : artpiece_path)
    #prefix + (artpiece_path || '')
  end

  def self.owned
    where("artist_id in (select id from users where state = 'active' and type='Artist')")
  end

  def self.get_new_art
    cache_key = NEW_ART_CACHE_KEY
    new_art = SafeCache.read(cache_key)
    unless new_art.present?
      new_art = ArtPiece.where('artist_id is not null && artist_id > 0').limit(12).order('created_at desc').all
      SafeCache.write(cache_key, new_art, :expires_in => NEW_ART_CACHE_EXPIRY)
    end
    new_art || []
  end

  private
  def clear_caches
    cache_key = NEW_ART_CACHE_KEY
    SafeCache.delete(cache_key)

    if self.artist && self.artist.id != nil?
      SafeCache.delete("%s%s" % [Artist::CACHE_KEY, self.artist.id])
    end
  end

  def remove_images
    paths = get_paths.values
    paths.each do |pth|
      pth = File.expand_path( File.join( Rails.root, 'public', pth ) )
      if File.exist? pth
        begin
          result = File.delete pth
          ::Rails.logger.debug("Deleted %s" % pth)
        rescue
          ::Rails.logger.error("Failed to delete image %s [%s]" % [pth, $!])
        end
      end
    end
  end

  def remove_old_art
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
