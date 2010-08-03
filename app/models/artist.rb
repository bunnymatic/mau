require 'digest/sha1'
require 'htmlhelper'
require 'json'
RESTRICTED_LOGIN_NAMES = [ 'addprofile','delete','destroy','deleteart',
                           'deactivate','add','new','view','create','update']

# here are names we should probably capture or disallow before we release
# the site.  maybe we make a migration to create these accounts
#'admin','root','mau', 'mauadmin','maudev',
#'jon','mrrogers','trish','trishtunney',

class Artist < ActiveRecord::Base

  @@ALLARTISTS_KEY = (Conf.cache_ns or '') + "artists"
  @@CACHE_EXPIRY =  (Conf.cache_expiry['objects'] or 0)

  # stash this so we don't have to keep getting it from the db
  attr_reader :emailsettings, :fullname, :address

  belongs_to :studio
  has_many :art_pieces
  has_and_belongs_to_many :roles

  acts_as_mappable
  before_validation_on_create :compute_geocode
  before_validation_on_update :compute_geocode

  after_save :flush_cache
  after_update :flush_cache
  after_destroy :flush_cache

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles

  validates_presence_of     :login
  validates_length_of       :login,    :within => 5..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_format_of       :name,     :with => Authentication.name_regex,  :message => Authentication.bad_name_message, :allow_nil => true
  validates_length_of       :name,     :maximum => 100

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_presence_of     :firstname  
  validates_length_of       :firstname,     :maximum => 100
  validates_presence_of     :lastname
  validates_length_of       :lastname,     :maximum => 100

  # custom validations
  #validate :validate_phone
  validate :validate_username

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :firstname, :lastname, :studio_id, :nomdeplume, :phone, :url, :street, :city, :addr_state, :zip, :bio, :facebook, :flickr, :myspace, :twitter, :blog, :year, :reset_code, :emailsettings, :email_attrs, :os2010, :lat, :lng


  # Authenticates a user by their login name and unencrypted password.  Returns the user or nil.
  #
  # uff.  this is really an authorization, not authentication routine.  
  # We really need a Dispatch Chain here or something.
  # This will also let us return a human error message.
  #
  def self.authenticate(login, password)
    return nil if login.blank? || password.blank?
    u = find_by_login(login.downcase) # need to get the salt
    u && u.authenticated?(password) ? u : nil
  end

  def login=(value)
    write_attribute :login, (value ? value.downcase : nil)
  end

  def email=(value)
    write_attribute :email, (value ? value.downcase : nil)
  end

  def has_profile_image
    self.profile_image
  end

  def get_profile_image(size)
    ArtistProfileImage.get_path(self, size)
  end

  def is_in_role?(role)
    if role.nil?
      return false;
    end
    return roles.include?(Role[role])
  end

  def get_share_link(urlsafe=false)
    link = 'http://%s/artists/%s' % [Conf.site_url, self.login]
    if urlsafe
      CGI::escape(link)
    else
      link
    end
  end

  def emailsettings
    JSON.parse(email_attrs)
  end

  def fancy_link()
    return "http://" + Conf.site_url + "/artists/" + self.login
  end

  def address
    if self.studio_id != 0
      return self.studio.address
    else
      if self.street && ! self.street.empty?
        return "%s %s" % [self.street, self.zip]
      end
    end
  end

  def fullname
    fullname = nil
    if !(self.firstname.empty? or self.lastname.empty?)
      fullname = [self.firstname, self.lastname].join(" ")
    end
    fullname
  end
  def get_name(htmlsafe=false)
    if self.nomdeplume
      name = self.nomdeplume
    else
      name = self.fullname
    end
    if not name
      name = self.login
    end
    if htmlsafe
      HTMLHelper.encode(name)
    else
      name
    end
  end

  def get_sort_name
    # get name for sorting:  try lastname, then firstname then login
    if !self.lastname.empty? && self.lastname[0].chr.match('[\w\d]')
      self.lastname.downcase
    elsif !self.firstname.empty? && self.firstname[0].chr.match('[\w\d]')
      self.firstname.downcase
    else
      self.login.downcase
    end
  end

  def representative_piece
    pc = self.representative_pieces
    if pc and pc.length 
      return pc[0]
    end
    nil
  end

  def representative_pieces(n=1)
    aps = []
    if self.representative_art_piece && self.representative_art_piece > 0
      begin
        rep = ArtPiece.find(self.representative_art_piece)
        aps << rep
      rescue ActiveRecord::RecordNotFound
        rep = nil
      end
    end
    ap = self.art_pieces.reverse
    if !ap.empty?
      # move rep to top if necessary
      len = ap.length
      num = [n, len].min
      if !rep
        return ap[0..num-1]
      else
        ap[0..num-1].each do |a| 
          if a.id != rep.id
            aps << a
          end
        end
      end
      return aps[0..num-1]
    end
    nil
  end

  def is_admin?
    begin
      self.roles.include? Role.find(1)
    rescue
      # if we have any issues, not admin
      false
    end 
  end

  def self.all
    begin
      artists = CACHE.get(@@ALLARTISTS_KEY)
    rescue
      logger.warn("Artist: Memcache seems to be dead")
      artists = nil
    end
    if ! artists
      logger.debug("Artist: Fetch from db")
      artists = super(:order => 'lastname, firstname', :conditions => { :activation_code => nil, :state => "active"})
      begin
        CACHE.set(@@ALLARTISTS_KEY, artists, @@CACHE_EXPIRY)
      rescue
        logger.warn("Artist: Failed to set artists in cache")
      end
    else
      logger.debug("Artist: Fetched from cache")
    end
    artists
  end

  def os2010?
    osend = DateTime.new(2010,04,27)
    self.os2010 && (DateTime.now < osend)
  end

  def tags
    # rollup and return most popular 15 tags
    if @mytags == nil
      logger.debug("Fetching my tags")
      tags = {}
      for ap in self.art_pieces
        if ap.tags
          ap.tags.each do |t| 
            tags[t.id] = t
          end
        end
      end
      @mytags = tags.values
    end
    @mytags
  end

  def media
    if @mymedia == nil
      media = {}
      for ap in self.art_pieces
        if ap.medium
          media[ap.medium.id] = ap.medium
        end
      end
      @mymedia = media.values
    end
    @mymedia
  end

  def flush_cache
    Artist.flush_cache
    Studio.flush_cache
  end

  def self.flush_cache
    logger.debug "Artists: Flushing cache"
    begin
      CACHE.delete(@@ALLARTISTS_KEY)
    rescue
      logger.warn("Artist: Memcache delete failed")
    end
    Studio.flush_cache
  end

  def validate_phone
    errors.add(:phone, 'is an invalid phone number, must contain at least 5 digits, only the following characters are allowed: 0-9/-()+') unless Artist.valid_phone?(phone)
  end

  def validate_username
    errors.add(:login, 'you requested is a reserved name.  Try a different login') unless Artist.valid_username?(login)
  end

  def self.valid_username?(user)
    if not user or user.empty?
      return false
    end
    return !RESTRICTED_LOGIN_NAMES.include?(user.downcase)
  end

  def self.valid_phone?(number)
    return true if number.nil?
    n_digits = number.scan(/[0-9]/).size
    valid_chars = (number =~ /^[+\/\-() 0-9]+$/)
    return n_digits > 5 && valid_chars
  end


  def resend_activation
    @resent_activation = true
    make_activation_code
    save(false)
  end

  def resent_activation?
    @resent_activation
  end

  def create_reset_code
    @reset = true
    self.attributes = {:reset_code => Digest::SHA1.hexdigest( Time.now.to_s.split(//).sort_by {rand}.join )}
    save(false)
  end 
  
  def recently_reset?
    @reset
  end 

  def delete_reset_code
    self.attributes = {:reset_code => nil}
    save(false)
  end

  def suspended?
    self.state == 'suspended'
  end

  # reformat data so that the artist contains the art pieces
  # and that any security related data is missing (salt, password etc)
  def clean_for_export( art_pieces)
    retval = { "artist" => {}, "artpieces" => [] }
    keys = [ 'firstname','lastname','login', 'street' ]
    keys.each do |k|
      retval["artist"][k] = self[k]
    end
    apkeys = ['title','filename']
    art_pieces.each do |ap|
      newap = {}
      apkeys.each do |k|
        newap[k] = ap[k]
      end
      retval["artpieces"] << newap
    end
    retval
  end

  protected
    def compute_geocode
      if self.studio_id != 0
        s = self.studio
        if s.lat && s.lng
          self.lat = s.lat
          self.lng = s.lng
        end
      else
        # use artist's address
        result = Geokit::Geocoders::MultiGeocoder.geocode("%s, %s, %s" % [self.street, self.state, self.zip])
        errors.add(:street, "Unable to Geocode your address.") if !result.success
        self.lat, self.lng = result.lat, result.lng if result.success
      end
    end

    def make_activation_code
        self.deleted_at = nil
        self.activation_code = self.class.make_token
    end

end
