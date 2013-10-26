require 'qr4r'

class Artist < User

  BOUNDS = { 'NW' => [ 37.76978184422388, -122.42683410644531 ],
    'NE' => [ 37.76978184422388, -122.40539789199829 ],
    'SW' => [ 37.747787573475506, -122.42919445037842 ],
    'SE' => [ 37.74707496171992, -122.40539789199829 ]
  }.freeze
  CACHE_KEY = 'a_rep' if !defined? CACHE_KEY

  include AddressMixin
  # note, if this is used with count it doesn't work properly - group_by is dumped from the sql
  scope :with_representative_image, joins(:art_pieces).group('art_pieces.artist_id')

  has_one :artist_info

  has_many :art_pieces, :order => "`order` ASC, `id` DESC"

  before_create :make_activation_code

  [:bio, :bio=,
   :facebook, :facebook=,
   :flickr, :flickr=,
   :twitter, :twitter=,
   :blog, :blog=,
   :myspace, :myspace=,
   :os_participation, :os_participation=,
   :street, :street=,
   :city, :city=,
   :addr_state, :addr_state=,
   :zip, :zip=,
   :lat, :lat=,
   :lng, :lng=
   ].each do |delegat|
    delegate delegat, :to => :artist_info, :allow_nil => true
  end
  delegate :update_os_participation, :to => :artist_info

  def to_json opts = {}
    default_opts = { :except => [:password, :crypted_password, :remember_token, :remember_token_expires_at, :salt, :mailchimp_subscribed_at, :deleted_at, :activated_at, :created_at, :max_pieces, :updated_at, :activation_code, :reset_code] }
    super(default_opts.merge(opts))
  end

  def in_the_mission?
    h = address_hash
    if h && h.has_key?(:latlng)
      lat = h[:latlng][0]
      lng = h[:latlng][1]
      sw = BOUNDS['SW']
      ne = BOUNDS['NE']
      if lat && lng
        (lat>sw[0] and lat<ne[0] and lng>sw[1] and lng<ne[1])
      else
        false
      end
    else
      false
    end
  end

  def doing_open_studios?
    Conf.oslive && os_participation[Conf.oslive.to_s]
  end

  def address
    call_address_method :address
  end

  def full_address
    call_address_method :full_address
  end

  def address_hash
    call_address_method :address_hash
  end

  def primary_medium
    freq = {}
    return nil unless art_pieces && art_pieces.count > 0
    art_pieces.map(&:medium).select{|m| m}.each do |m|
      freq[m.id] = 0 unless freq.has_key? m.id
      freq[m.id] += 1
    end
    return nil unless freq && freq.count > 0
    sorted = freq.sort{|a,b| b[1] <=> a[1]}.map{|f| [Medium.find(f[0]), f[1]]}

    sorted[0][0]
  end

  def representative_piece
    cache_key = "%s%s" % [CACHE_KEY, id]
    piece = SafeCache.read(cache_key)
    if piece.nil?
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
      lower_names = [names].flatten.map { |n| n.downcase }
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
      conf = Conf.oslive.to_s
      recorded_on = today

      o = OpenStudiosTally.find_by_recorded_on(today)
      if o
        o.update_attributes(:oskey => conf, :count => count)
      else
        OpenStudiosTally.create!(:oskey => conf, :count => count, :recorded_on => today)
      end

    end
  end

  def self.open_studios_participants(oskey = nil)
    q = (oskey || Conf.oslive).to_s
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
