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
#  image_height              :integer          default(0)
#  image_width               :integer          default(0)
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
#
# Indexes
#
#  index_artists_on_login            (login) UNIQUE
#  index_users_on_last_request_at    (last_request_at)
#  index_users_on_persistence_token  (persistence_token)
#  index_users_on_state              (state)
#  index_users_on_studio_id          (studio_id)
#

require 'qr4r'

class Artist < User

  KEYED_LINKS = [ [:url, 'Website', :u_website],
                  [:instagram, 'Instagram', :u_instagram],
                  [:facebook, 'Facebook', :u_facebook],
                  [:twitter, 'Twitter', :u_twitter],
                  [:pinterest, 'Pinterest', :u_pinterest],
                  [:flickr, 'Flickr', :u_flickr],
                  [:blog, 'Blog', :u_blog],
                  [:myspace, 'MySpace', :u_myspace]]


  BOUNDS = { 'NW' => [ 37.76978184422388, -122.42683410644531 ],
    'NE' => [ 37.76978184422388, -122.40539789199829 ],
    'SW' => [ 37.747787573475506, -122.42919445037842 ],
    'SE' => [ 37.74707496171992, -122.40539789199829 ]
  }.freeze
  CACHE_KEY = 'a_rep' if !defined? CACHE_KEY

  include AddressMixin
  include OpenStudiosEventShim

  # note, if this is used with count it doesn't work properly - group_by is dumped from the sql
  scope :with_representative_image, joins(:art_pieces).group('art_pieces.artist_id')
  scope :with_artist_info, includes(:artist_info)
  scope :by_lastname, order(:lastname)
  scope :by_firstname, order(:firstname)

  has_one :artist_info
  accepts_nested_attributes_for :artist_info

  has_many :art_pieces, :order => "`order` ASC, `id` DESC"

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

  def to_json opts = {}
    default_opts = {
      :except => [:password, :crypted_password, :remember_token, :remember_token_expires_at,
                  :salt, :mailchimp_subscribed_at, :deleted_at, :activated_at, :created_at,
                  :max_pieces, :updated_at, :activation_code, :reset_code]
    }
    super(default_opts.merge(opts))
  end

  def in_the_mission?
    return false unless address_hash && address_hash.has_key?(:latlng)
    lat,lng = address_hash[:latlng]
    sw = BOUNDS['SW']
    ne = BOUNDS['NE']
    !!((lat && lng) && (lat>sw[0] && lat<ne[0] && lng>sw[1] && lng<ne[1]))
  end

  def in_a_group_studio?
    (studio_id.present? && studio_id != 0 && studio.present?)
  end

  def doing_open_studios?
    !!(current_open_studios_key && os_participation && os_participation[current_open_studios_key.to_s])
  end

  def address
    @memo_address ||= call_address_method :address
  end

  def full_address
    @memo_full_address ||= call_address_method :full_address
  end

  def address_hash
    @memo_address_hash ||= call_address_method :address_hash
  end

  def primary_medium
    return nil unless art_pieces && art_pieces.count > 0
    @primary_medium ||=
      begin
        hist = histogram(art_pieces.map(&:medium).compact)
        hist.sort_by{|k,v| v}.last.try(:first)
      end
  end

  def representative_piece
    cache_key = "%s%s" % [CACHE_KEY, id]
    piece = SafeCache.read(cache_key)
    if piece.blank?
      logger.debug('cache miss');
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

    def find_all_by_fullname( names )
      inclause = ""
      lower_names = [names].flatten.map { |n| n.downcase.strip }
      sql = "select * from users where (lower(concat_ws(' ', firstname, lastname)) in (?)) and type='Artist'"
      find_by_sql [sql, lower_names]
    end

    def find_by_fullname( name )
      find_all_by_fullname([name])
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
    q = (oskey || self.current_open_studios_key).to_s
    joins(:artist_info).where("artist_infos.open_studios_participation like '%#{q}%'")
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
