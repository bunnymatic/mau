# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string(40)
#  name                      :string(100)      default("")
#  email                     :string(100)
#  crypted_password          :string(128)      default(""), not null
#  password_salt             :string(128)      default(""), not null
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  firstname                 :string(40)
#  lastname                  :string(40)
#  nomdeplume                :string(80)
#  url                       :string(200)
#  profile_image             :string(200)
#  studio_id                 :integer
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)      default("passive")
#  deleted_at                :datetime
#  reset_code                :string(40)
#  email_attrs               :string(255)      default("{\"fromartist\": true, \"favorites\": true, \"fromall\": true}")
#  type                      :string(255)      default("Artist")
#  mailchimp_subscribed_at   :date
#  persistence_token         :string(255)
#  login_count               :integer          default(0), not null
#  last_request_at           :datetime
#  last_login_at             :datetime
#  current_login_at          :datetime
#  last_login_ip             :string(255)
#  current_login_ip          :string(255)
#  slug                      :string(255)
#  photo_file_name           :string(255)
#  photo_content_type        :string(255)
#  photo_file_size           :integer
#  photo_updated_at          :datetime
#
# Indexes
#
#  index_artists_on_login            (login) UNIQUE
#  index_users_on_last_request_at    (last_request_at)
#  index_users_on_persistence_token  (persistence_token)
#  index_users_on_slug               (slug) UNIQUE
#  index_users_on_state              (state)
#  index_users_on_studio_id          (studio_id)
#

require 'qr4r'

class Artist < User
  # thanks, http://www.gps-coordinates.net/
  # order is important for the js overlay
  BOUNDS = {
    'NW' => [
      37.770, -122.430
    ],
    'SW' => [
      37.747, -122.430
    ],
    'SE' => [
      37.747, -122.404
    ],
    'NE' => [
      37.770, -122.404
    ]
  }.freeze

  CACHE_KEY = 'a_rep' if !defined? CACHE_KEY
  MAX_PIECES = 20
  include AddressMixin
  include OpenStudiosEventShim

  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks
  settings do
    mappings(_all: {analyzer: :snowball}) do
      indexes :artist_name, analyzer: :snowball
      indexes :firstnaem, analyzer: :snowball
      indexes :lastname, analyzer: :snowball
      indexes :nomdeplume, analyzer: :snowball
      indexes :studio_name, analyzer: :snowball
      indexes :bio, index: :no
    end
  end

  def as_indexed_json(opts={})
    idxd = as_json(only: [:firstname, :lastname, :nomdeplume, :slug])
    extras = {}
    studio_name = studio.try(:name)
    extras["artist_name"] = full_name
    extras["studio_name"] = studio_name if studio_name.present?
    extras["images"] = representative_piece.try(:image_paths)
    extras["bio"] = bio if bio.present?
    idxd["artist"].merge!(extras)
    puts idxd if (active? && extras["images"].present?)
    (active? && extras["images"].present?) ? idxd : {}
  end
  
  # note, if this is used with count it doesn't work properly - group_by is dumped from the sql
  scope :with_representative_image, joins(:art_pieces).group('art_pieces.artist_id')
  scope :with_artist_info, includes(:artist_info)
  scope :by_lastname, order(:lastname)
  scope :without_art, active.where("id not in (select artist_id from art_pieces)");

  has_one :artist_info
  accepts_nested_attributes_for :artist_info

  has_many :art_pieces, :order => "`position` ASC, `created_at` desc"

  before_create :make_activation_code

  [:bio, :bio=,
   :facebook, :flickr, :twitter, :blog,:myspace, :pinterest, :instagram,
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
    !!((lat && lng) && (lat>sw[0] && lat<ne[0] && lng>sw[1] && lng<ne[1]))
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

  def latest_piece
    @latest_piece ||= art_pieces.order('created_at desc').limit(1).first
  end

  def representative_piece
    cache_key = "%s%s" % [CACHE_KEY, id]
    piece = SafeCache.read(cache_key)
    if piece.blank?
      logger.debug("#{__method__}: cache miss");
      piece = art_pieces.first
      SafeCache.write(cache_key, piece, :expires_in => 0) unless piece.nil?
    end
    piece
  end

  def representative_pieces(n)
    ap = art_pieces[0..n-1]
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

    def find_all_by_full_name( names )
      inclause = ""
      lower_names = [names].flatten.map { |n| n.downcase.strip }
      sql = "select * from users where (lower(concat_ws(' ', firstname, lastname)) in (?)) and type='Artist'"
      find_by_sql [sql, lower_names]
    end

    def find_by_full_name( name )
      find_all_by_full_name([name])
    end

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
