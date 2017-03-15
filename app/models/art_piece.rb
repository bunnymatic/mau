# frozen_string_literal: true
class ArtPiece < ApplicationRecord
  belongs_to :artist

  has_many :art_pieces_tags
  has_many :tags, through: :art_pieces_tags, source: :art_piece_tag

  belongs_to :medium

  include TagsHelper

  has_attached_file :photo, styles: MauImage::Paperclip::STANDARD_STYLES, default_url: ''
  validates_attachment_presence :photo
  validates_attachment_content_type :photo,
                                    content_type: ['image/jpg', 'image/jpeg', 'image/png', 'image/gif'],
                                    message: 'Only JPEG, PNG, and GIF images are allowed'
  validates :artist_id, presence: true
  include Elasticsearch::Model

  after_commit :add_to_search_index, on: :create
  after_commit :refresh_in_search_index, on: :update
  after_commit :remove_from_search_index, on: :destroy

  def add_to_search_index
    Search::Indexer.index(self)
  end

  def refresh_in_search_index
    Search::Indexer.reindex(self)
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    add_to_search_index
  end

  def remove_from_search_index
    Search::Indexer.remove(self)
  end

  __elasticsearch__.client = Search::EsClient.root_es_client

  settings(analysis: Search::Indexer::ANALYZERS_TOKENIZERS, index: { number_of_shards: 2 }) do
    mappings(_all: { analyzer: :mau_snowball_analyzer }) do
      indexes :title, analyzer: :mau_snowball_analyzer
      indexes :year
      indexes :medium, analyzer: :mau_snowball_analyzer
      indexes :artist_name, analyzer: :mau_snowball_analyzer
      indexes :studio_name, analyzer: :mau_snowball_analyzer
      indexes :tags, analyzer: :mau_snowball_analyzer
    end
  end

  # after_destroy :remove_images
  after_destroy :clear_tags_and_favorites
  after_save :remove_old_art
  after_save :clear_caches

  validates :title, presence: true
  validates :title, length: { within: 2..80 }

  def as_indexed_json(_opts = {})
    return {} unless artist && artist.active?

    idxd = as_json(only: [:title, :year])
    extras = {}
    extras['medium'] = medium.try(:name)
    extras['tags'] = tags.map(&:name).join(', ')
    extras['images'] = image_paths
    # guard against bad data
    extras['artist_name'] = artist.full_name
    extras['studio_name'] = artist.studio.name if artist.studio
    extras['os_participant'] = artist.doing_open_studios?

    idxd['art_piece'].merge! extras
    idxd
  end

  def self.find_random(num = 1)
    owned.limit(num).order('rand()')
  end

  def self.owned
    joins(:artist).where(users: { state: 'active' })
  end

  def tags
    super.alpha
  end

  def clear_tags_and_favorites
    klassname = self.class.name
    Favorite.where(favoritable_id: id, favoritable_type: klassname).compact.map(&:destroy)
  end

  def uniq_tags
    tags.uniq_by(&:name)
  end

  def get_name(escape = false)
    escape ? safe_title : title
  end

  def safe_title
    HtmlEncoder.encode(title)
  end

  def path(size)
    photo(size) if photo?
  end

  def paths
    @paths ||=
      begin
        MauImage::ImageSize.allowed_sizes.each_with_object({}) do |size, memo|
          memo[size] = path(size)
        end
      end
  end

  alias image_paths paths

  private

  def clear_caches
    ArtPieceCacheService.clear
    SafeCache.delete(artist.representative_art_cache_key) if artist && artist.id != nil?
  end

  def remove_old_art
    # mostly this makes stuff work for testing
    return unless artist

    max = artist.max_pieces
    cur = artist.art_pieces.length
    del = 0
    while cur && max && (cur > max)
      artist.art_pieces.last.destroy
      cur -= 1
      del += 1
    end
  end
end
