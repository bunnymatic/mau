# == Schema Information
#
# Table name: art_pieces
#
#  id                 :integer          not null, primary key
#  filename           :string(255)
#  title              :string(255)
#  description        :text
#  dimensions         :string(255)
#  artist_id          :integer
#  created_at         :datetime
#  updated_at         :datetime
#  medium_id          :integer
#  year               :integer
#  position           :integer          default(0)
#  photo_file_name    :string(255)
#  photo_content_type :string(255)
#  photo_file_size    :integer
#  photo_updated_at   :datetime
#
# Indexes
#
#  index_art_pieces_on_artist_id  (artist_id)
#  index_art_pieces_on_medium_id  (medium_id)
#

class ArtPiece < ActiveRecord::Base
  belongs_to :artist

  has_many :art_pieces_tags
  has_many :tags, :through => :art_pieces_tags, :source => :art_piece_tag

  belongs_to :medium

  include HtmlHelper
  include TagsHelper

  has_attached_file :photo, styles: MauImage::Paperclip::STANDARD_STYLES, default_url: ''
  validates_attachment_presence :photo
  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/
  include Elasticsearch::Model

  after_commit :add_to_search_index, on: :create
  after_commit :refresh_in_search_index, on: :update
  after_commit :remove_from_search_index, on: :destroy

  def add_to_search_index
    Search::Indexer.index(self)
  end

  def refresh_in_search_index
    Search::Indexer.reindex(self)
  end

  def remove_from_search_index
    Search::Indexer.remove(self)
  end


  settings do
    mappings(_all: {analyzer: :snowball}) do
      indexes :title, analyzer: :snowball
      indexes :year
      indexes :medium, analyzer: :snowball
      indexes :artist_name, analyzer: :snowball
      indexes :studio_name, analyzer: :snowball
      indexes :tags, analyzer: :snowball
    end
  end

  before_destroy :remove_images
  after_destroy :clear_tags_and_favorites
  after_save :remove_old_art
  after_save :clear_caches

  validates_presence_of     :title
  validates_length_of       :title,    :within => 2..80

  def as_indexed_json(opts={})
    idxd = as_json(only: [:title, :year])
    extras = {}
    extras["medium"] = medium.try(:name)
    extras["tags"] = tags.map(&:name).join(", ")
    extras["artist_name"] = artist.try(:full_name)
    extras["studio_name"] = artist.try(:studio).try(:name) if artist.studio
    extras["images"] = image_paths
    extras["os_participant"] = artist.try(:doing_open_studios?)
    idxd["art_piece"].merge! extras
    idxd
  end


  def self.owned
    where("artist_id in (select id from users where state = 'active' and type='Artist')")
  end

  def tags
    super.alpha
  end


  def clear_tags_and_favorites
    klassname = self.class.name
    Favorite.where(:favoritable_id => id, :favoritable_type => klassname).compact.map(&:destroy)
  end

  def uniq_tags
    tags.uniq_by(&:name)
  end

  def get_name(escape = false)
    escape ? safe_title : self.title
  end

  def safe_title
    html_encode(self.title)
  end

  def get_path(size = nil, full_path = false)
    size ||= 'medium'
    artpiece_path = image_paths[size.to_sym]
    (full_path ? full_image_path(artpiece_path) : artpiece_path)
  end

  def image_paths
    @image_paths ||= ArtPieceImage.new(self).paths
  end

  def get_paths
    image_paths
  end

  private
  def clear_caches
    ArtPieceService.clear_cache
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
      while cur && max && (cur > max)
        artist.art_pieces.last.destroy
        cur = cur - 1
        del = del + 1
      end
    end
  end

end
