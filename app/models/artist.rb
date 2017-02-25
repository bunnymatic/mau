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
      indexes :bio, index: :no
    end
  end

  def as_indexed_json(_opts = {})
    return {} unless active?
    idxd = as_json(only: [:firstname, :lastname, :nomdeplume, :slug])
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
  scope :with_artist_info, -> { includes(:artist_info) }
  scope :by_lastname, -> { order(:lastname) }
  scope :without_art, -> { active.where('id not in (select artist_id from art_pieces)') }

  has_one :artist_info, dependent: :destroy
  accepts_nested_attributes_for :artist_info, update_only: true

  has_many :art_pieces, -> { order(position: :asc, created_at: :desc) }

  before_create :make_activation_code

  [
    :bio, :bio=, :lat, :lng, :city, :street, :addr_state, :zip,
    :os_participation, :os_participation=, :max_pieces
  ].each do |delegat|
    delegate delegat, to: :artist_info, allow_nil: true
  end
  delegate :update_os_participation, to: :artist_info

  def at_art_piece_limit?
    art_pieces.select(&:persisted?).count >= (max_pieces || MAX_PIECES)
  end

  def profile_images
    images = MauImage::ImageSize.allowed_sizes.map do |key|
      [key, get_profile_image(key)]
    end
    Hash[images]
  end

  def in_the_mission?
    return false unless address?
    within_bounds?(address.lat, address.lng)
  end

  def in_a_group_studio?
    (studio_id.present? && studio_id != 0 && studio.present?)
  end

  def doing_open_studios?
    @doing_open_studios ||=
      begin
        (current_open_studios_key && os_participation && os_participation[current_open_studios_key.to_s])
      end
  end

  alias doing_open_studios doing_open_studios?

  def representative_piece
    piece_id = SafeCache.read(representative_art_cache_key)
    piece = ArtPiece.find_by id: piece_id

    if piece.blank?
      logger.debug("#{__method__}: cache miss")
      piece = art_pieces.first
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
      count = Artist.open_studios_participants.count

      o = OpenStudiosTally.find_by(recorded_on: today)
      if o
        o.update_attributes(oskey: current_open_studios_key, count: count)
      else
        OpenStudiosTally.create!(oskey: current_open_studios_key, count: count, recorded_on: today)
      end
    end
  end

  def self.open_studios_participants(oskey = nil)
    q = (oskey || OpenStudiosEventService.current.try(:key)).to_s
    if q.present?
      joins(:artist_info).where("artist_infos.open_studios_participation like '%#{q}%'")
    else
      where('1 = 0')
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
