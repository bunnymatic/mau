require 'qr4r'

class Artist < User

  # thanks, http://www.gps-coordinates.net/
  # order is important for the js overlay
  EAST_BOUNDARY = -122.40399999999999
  WEST_BOUNDARY = -122.430
  NORTH_BOUNDARY = 37.7751
  SOUTH_BOUNDARY = 37.747
  BOUNDS = {
    'NW' => [
      NORTH_BOUNDARY, WEST_BOUNDARY
    ],
    'SW' => [
      SOUTH_BOUNDARY, WEST_BOUNDARY
    ],
    'SE' => [
      SOUTH_BOUNDARY, EAST_BOUNDARY
    ],
    'NE' => [
      NORTH_BOUNDARY, EAST_BOUNDARY
    ]
  }.freeze

  REPRESENTATIVE_ART_CACHE_KEY = 'representative_art'
  MAX_PIECES = 20
  include AddressMixin
  include OpenStudiosEventShim

  include Elasticsearch::Model

  extend FriendlyId
  friendly_id :login, use: [:slugged, :finders]

  self.__elasticsearch__.client = Search::EsClient.root_es_client

  after_commit :add_to_search_index, on: :create
  after_commit :remove_from_search_index, on: :destroy
  # after_commit :refresh_in_search_index, on: :update

  def add_to_search_index
    Search::Indexer.index(self)
  end

  def remove_from_search_index
    Search::Indexer.remove(self)
  end

  settings(analysis: Search::Indexer::ANALYZERS_TOKENIZERS, index: { number_of_shards: 2}) do
    mappings(_all: {analyzer: :mau_snowball_analyzer}) do
      indexes :artist_name, analyzer: :mau_snowball_analyzer
      indexes :firstname, analyzer: :mau_snowball_analyzer
      indexes :lastname, analyzer: :mau_snowball_analyzer
      indexes :nomdeplume, analyzer: :mau_snowball_analyzer
      indexes :studio_name, analyzer: :mau_snowball_analyzer
      indexes :bio, index: :no
    end
  end

  def as_indexed_json(opts={})
    return {} unless active?
    idxd = as_json(only: [:firstname, :lastname, :nomdeplume, :slug])
    extras = {}
    studio_name = studio.try(:name)
    extras["artist_name"] = full_name
    extras["studio_name"] = studio_name if studio_name.present?
    extras["images"] = representative_piece.try(:image_paths)
    extras["bio"] = bio if bio.present?
    extras["os_participant"] = doing_open_studios?
    idxd["artist"].merge!(extras)
    (active? && extras["images"].present?) ? idxd : {}
  end

  # note, if this is used with count it doesn't work properly - group_by is dumped from the sql
  scope :with_representative_image, -> { joins(:art_pieces).group('art_pieces.artist_id') }
  scope :with_artist_info, -> { includes(:artist_info) }
  scope :by_lastname, -> { order(:lastname) }
  scope :without_art, -> { active.where("id not in (select artist_id from art_pieces)") }

  has_one :artist_info, dependent: :destroy
  accepts_nested_attributes_for :artist_info, update_only: true

  has_many :art_pieces, -> { order(position: :asc, created_at: :desc) }

  before_create :make_activation_code

  [:bio, :bio=,
   :os_participation, :os_participation=,
   :street, :street=,
   :city, :city=,
   :addr_state, :addr_state=,
   :zip, :zip=,
   :lat, :lat=,
   :lng, :lng=,
   :max_pieces
   ].each do |delegat|
    delegate delegat, :to => :artist_info, :allow_nil => true
  end
  delegate :update_os_participation, :to => :artist_info

  def at_art_piece_limit?
    art_pieces.select(&:persisted?).count >= (max_pieces || MAX_PIECES)
  end

  def profile_images
    images = MauImage::ImageSize.allowed_sizes.map do |key|
      [key,get_profile_image(key)]
    end
    Hash[images]
  end

  def in_the_mission?
    return false unless address && address_hash.has_key?(:latlng)
    lat,lng = address_hash[:latlng]
    sw = BOUNDS['SW']
    ne = BOUNDS['NE']
    !!((lat && lng) && (lat >= sw[0] && lat <= ne[0] && lng >= sw[1] && lng <= ne[1]))
  end

  def in_a_group_studio?
    (studio_id.present? && studio_id != 0 && studio.present?)
  end

  def doing_open_studios?
    @doing_open_studios ||= !!(current_open_studios_key && os_participation && os_participation[current_open_studios_key.to_s])
  end
  alias_method :doing_open_studios, :doing_open_studios?

  def address
    @memo_address ||= call_address_method :address
  end

  def full_address
    @memo_full_address ||= call_address_method :full_address
  end

  def address_hash
    @memo_address_hash ||= call_address_method :address_hash
  end

  def representative_piece
    cache_key = "%s%s" % [REPRESENTATIVE_ART_CACHE_KEY, id]
    piece_id = SafeCache.read(cache_key)
    piece = ArtPiece.find_by id: piece_id
    if piece.blank?
      logger.debug("#{__method__}: cache miss");
      piece = art_pieces.first
      SafeCache.write(cache_key, piece.id, :expires_in => 0) unless piece.nil?
    end
    piece
  end

  def qrcode opts = {}
    path = File.join(Rails.root, "public/artistdata/#{id}/profile/qr.png")
    qropts = {:border => 15, :pixel_size => 5}.merge(opts)
    if !File.exists? path
      artist_url = "http://%s/%s?%s" % [Conf.site_url, "artists/#{id}", "qrgen=auto"]
      path = Qr4r::encode(artist_url, path, qropts)
    end
    return path
  end

  class << self

    # tally up today's open studios count
    def tally_os
      today = Time.zone.now.to_date
      count = Artist.open_studios_participants.count
      recorded_on = today

      o = OpenStudiosTally.find_by_recorded_on(today)
      if o
        o.update_attributes(:oskey => current_open_studios_key, :count => count)
      else
        OpenStudiosTally.create!(:oskey => current_open_studios_key, :count => count, :recorded_on => today)
      end

    end
  end

  def self.open_studios_participants(oskey = nil)
    q = (oskey || OpenStudiosEventService.current.try(:key)).to_s
    if q.present?
      joins(:artist_info).where("artist_infos.open_studios_participation like '%#{q}%'")
    else
      where("1 = 0")
    end
  end

  protected
  def call_address_method(method)
    if studio_id != 0 and studio
      studio.send method
    else
      if artist_info
        artist_info.send method
      end
    end
  end
end
