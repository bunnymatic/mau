class ArtPiece < ApplicationRecord
  belongs_to :artist

  has_many :art_pieces_tags
  has_many :tags, through: :art_pieces_tags, source: :art_piece_tag, dependent: :destroy

  belongs_to :medium, optional: true

  include HasAttachedImage
  image_attachments(:photo)
  validates :photo, attached: true, size: { less_than: 8.megabytes }, content_type: %i[png jpg jpeg gif]

  validates :price, numericality: { greater_than_or_equal_to: 0.01, less_than_or_equal_to: 99_999_999 }, allow_nil: true

  include Elasticsearch::Model

  attr_accessor :sold

  # after_destroy :remove_images
  after_destroy :clear_tags_and_favorites
  after_save :clear_caches
  after_save :remove_old_art
  after_commit :add_to_search_index, on: :create
  after_commit :refresh_in_search_index, on: :update
  after_commit :remove_from_search_index, on: :destroy

  before_validation do
    # checkbox from formastic uses '1' for true
    self.sold_at = sold == '1' ? Time.current : nil
  end

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

  index_name name.underscore.pluralize
  document_type name.underscore

  settings(
    analysis: Search::Indexer::ANALYZERS_TOKENIZERS,
    index: Search::Indexer::INDEX_SETTINGS,
  ) do
    mappings(dynamic: false) do
      indexes :'art_piece.title', analyzer: 'english'
      indexes :'art_piece.title_ngram', analyzer: :mau_ngram_analyzer
      indexes :'art_piece.year'
      indexes :'art_piece.medium', analyzer: :mau_ngram_analyzer
      indexes :'art_piece.artist_name', analyzer: :mau_ngram_analyzer
      indexes :'art_piece.studio_name', analyzer: :mau_ngram_analyzer
      indexes :'art_piece.tags', analyzer: 'english'
    end
  end

  validates :title, presence: true
  validates :title, length: { within: 2..80 }

  def as_indexed_json(_opts = {})
    return {} unless artist&.active?

    idxd = as_json(only: %i[title year])
    extras = {}
    extras['title_ngram'] = title
    extras['medium'] = medium.try(:name)
    extras['tags'] = tags.map(&:name).join(' ')
    extras['images'] = images
    # guard against bad data
    extras['artist_name'] = artist.full_name
    extras['studio_name'] = artist.studio.name if artist.studio
    extras['os_participant'] = artist.doing_open_studios?

    idxd['art_piece'].merge! extras
    idxd
  end

  def self.find_random(num = 1)
    owned.limit(num).order(Arel.sql('rand()'))
  end

  def self.owned
    joins(:artist).where(users: { state: Constants::User::STATE_ACTIVE })
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

  def get_name(escape: false)
    escape ? safe_title : title
  end

  def safe_title
    HtmlEncoder.encode(title)
  end

  def image(size = :medium)
    attached_photo(size)
  end

  def images
    @images ||=
      MauImage::ImageSize.allowed_sizes.index_with do |size|
        image(size)
      end
  end

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

  class << self
    def paperclip_attachment_name
      :photo
    end
  end
end
