require 'qr4r'

class Artist < User
  MAX_PIECES = 20

  include MissionBoundaries
  include Elasticsearch::Model

  extend FriendlyId
  friendly_id :login, use: [:slugged]

  __elasticsearch__.client = Search::EsClient.root_es_client

  index_name name.underscore.pluralize
  document_type name.underscore

  settings(
    analysis: Search::Indexer::ANALYZERS_TOKENIZERS,
    index: Search::Indexer::INDEX_SETTINGS,
  ) do
    mapping dynamic: false do
      indexes :"artist.artist_name", analyzer: :mau_ngram_analyzer
      indexes :"artist.firstname", analyzer: :mau_ngram_analyzer
      indexes :"artist.lastname", analyzer: :mau_ngram_analyzer
      indexes :"artist.nomdeplume", analyzer: :mau_ngram_analyzer
      indexes :"artist.studio_name", analyzer: :mau_ngram_analyzer
      indexes :"artist.bio", index: false
    end
  end

  before_create :make_activation_code
  after_commit :add_to_search_index, on: :create
  after_commit :remove_from_search_index, on: :destroy
  # after_commit :refresh_in_search_index, on: :update

  def add_to_search_index
    Search::Indexer.index(self)
  end

  def remove_from_search_index
    Search::Indexer.remove(self)
  end

  def as_indexed_json(_opts = {})
    return {} unless active?

    idxd = as_json(only: %i[firstname lastname nomdeplume slug])
    extras = {}
    studio_name = studio.try(:name)
    extras['artist_name'] = full_name
    extras['studio_name'] = studio_name if studio_name.present?
    extras['images'] = representative_piece.try(:image_paths)
    extras['bio'] = bio if bio.present?
    extras['os_participant'] = doing_open_studios?
    idxd['artist'].merge!(extras)
    active? && extras['images'].present? ? idxd : {}
  end

  # note, if this is used with count it doesn't work properly - group_by is dumped from the sql
  scope :with_representative_image, -> { joins(:art_pieces).group('art_pieces.artist_id') }
  scope :by_lastname, -> { order(:lastname) }
  scope :without_art, -> { active.where('id not in (select artist_id from art_pieces)') }
  scope :in_a_group_studio, -> { where('studio_id <> 0').joins(:studio) }
  scope :independent_studio, -> { where('studio_id IS NULL or studio_id = 0') }

  scope :in_the_mission, lambda {
    # avoid sql between (in mysql) because it's not smart about floats
    def between_clause(fld)
      "(#{fld} >= ? AND #{fld} <= ?)"
    end

    joins(:artist_info, 'LEFT JOIN `studios` ON `studios`.id = `users`.`studio_id`').where(
      ["(#{between_clause('artist_infos.lat')} and #{between_clause('artist_infos.lng')}) or " \
       "(#{between_clause('studios.lat')} and #{between_clause('studios.lng')})",
       SOUTH_BOUNDARY, NORTH_BOUNDARY,
       WEST_BOUNDARY, EAST_BOUNDARY,
       SOUTH_BOUNDARY, NORTH_BOUNDARY,
       WEST_BOUNDARY, EAST_BOUNDARY],
    )
  }
  has_one :artist_info, dependent: :destroy
  accepts_nested_attributes_for :artist_info, update_only: true

  has_many :art_pieces, -> { order(position: :asc, created_at: :desc) }, inverse_of: :artist

  %i[
    bio
    bio=
    max_pieces
  ].each do |delegat|
    delegate delegat, to: :artist_info, allow_nil: true
  end

  delegate :full_address, :map_link, to: :address_holder, allow_nil: true

  def address
    address_holder&.address
  end

  def at_art_piece_limit?
    art_pieces.count(&:persisted?) >= (max_pieces || MAX_PIECES)
  end

  def profile_images
    images = MauImage::ImageSize.allowed_sizes.map do |key|
      [key, get_profile_image(key)]
    end
    images.to_h
  end

  def can_register_for_open_studios?
    studio.present? || address.present?
  end

  def in_the_mission?
    return false unless address.present? && address.geocoded?

    within_bounds?(address.lat, address.lng)
  end

  def current_open_studios_participant
    open_studios_participants.find_by(open_studios_event: OpenStudiosEventService.current)
  end

  def doing_open_studios?
    !!current_open_studios_participant
  end

  # for serializers that don't like keys with ?
  alias doing_open_studios doing_open_studios?

  def representative_piece
    piece_id = SafeCache.read(representative_art_cache_key)
    piece = art_pieces.find(piece_id) if piece_id

    if piece.blank?
      piece = art_pieces.first
      SafeCache.write(representative_art_cache_key, piece.id, expires_in: 0) unless piece.nil?
    end
    piece
  end

  def representative_art_cache_key
    @representative_art_cache_key ||= CacheKeyService.representative_art(self)
  end

  private

  def address_holder
    if studio
      studio
    elsif artist_info
      artist_info
    end
  end
end
