# frozen_string_literal: true

require 'qr4r'

class Artist < User
  MAX_PIECES = 20

  include MissionBoundaries
  include AddressMixin
  include OpenStudiosEventShim

  include Elasticsearch::Model

  extend FriendlyId
  friendly_id :login, use: [:slugged]

  __elasticsearch__.client = Search::EsClient.root_es_client

  after_commit :add_to_search_index, on: :create
  after_commit :remove_from_search_index, on: :destroy
  # after_commit :refresh_in_search_index, on: :update

  def add_to_search_index
    Search::Indexer.index(self)
  end

  def remove_from_search_index
    Search::Indexer.remove(self)
  end

  settings(analysis: Search::Indexer::ANALYZERS_TOKENIZERS, index: { number_of_shards: 2 }) do
    mappings(_all: { analyzer: :mau_snowball_analyzer }) do
      indexes :artist_name, analyzer: :mau_snowball_analyzer
      indexes :firstname, analyzer: :mau_snowball_analyzer
      indexes :lastname, analyzer: :mau_snowball_analyzer
      indexes :nomdeplume, analyzer: :mau_snowball_analyzer
      indexes :studio_name, analyzer: :mau_snowball_analyzer
      indexes :bio, index: false
    end
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

  before_create :make_activation_code

  %i[
    addr_state
    bio
    bio=
    city
    lat
    lng
    max_pieces
    street
    zip
  ].each do |delegat|
    delegate delegat, to: :artist_info, allow_nil: true
  end

  def at_art_piece_limit?
    art_pieces.select(&:persisted?).count >= (max_pieces || MAX_PIECES)
  end

  def profile_images
    images = MauImage::ImageSize.allowed_sizes.map do |key|
      [key, get_profile_image(key)]
    end
    Hash[images]
  end

  def can_register_for_open_studios?
    studio.present? || address.present?
  end

  def in_the_mission?
    return false unless address?

    within_bounds?(address.lat, address.lng)
  end

  def doing_open_studios?(key = nil)
    os = key ? OpenStudiosEventService.find_by(key: key) : OpenStudiosEventService.current
    !!(os && open_studios_events.find_by(id: os.to_param))
  end

  alias doing_open_studios doing_open_studios?

  def representative_piece
    piece_id = SafeCache.read(representative_art_cache_key)
    piece = ArtPiece.find_by id: piece_id

    if piece.blank?
      piece = art_pieces.min_by { |ap| [ap.position.to_i, -ap.created_at.to_i] }
      SafeCache.write(representative_art_cache_key, piece.id, expires_in: 0) unless piece.nil?
    end
    piece
  end

  def representative_art_cache_key
    @representative_art_cache_key ||= CacheKeyService.representative_art(self)
  end

  class << self
    # tally up today's open studios count
    def tally_os
      today = Time.zone.now.to_date
      count = OpenStudiosEventService.current.try(:artists).count

      o = OpenStudiosTally.find_by(recorded_on: today)
      if o
        o.update(oskey: current_open_studios_key, count: count)
      else
        OpenStudiosTally.create!(oskey: current_open_studios_key, count: count, recorded_on: today)
      end
    end
  end

  protected

  def call_address_method(method)
    if (studio_id != 0) && studio
      studio.send method
    elsif artist_info
      artist_info.send method
    end
  end
end
