require 'digest/sha1'
require 'htmlhelper'
require 'json'
require 'lib/mailchimp'
RESTRICTED_LOGIN_NAMES = [ 'addprofile','delete','destroy','deleteart',
                           'deactivate','add','new','view','create','update',
                         'arrangeart', 'setarrangement']

# here are names we should probably capture or disallow before we release
# the site.  maybe we make a migration to create these accounts
#'admin','root','mau', 'mauadmin','maudev',
#'jon','mrrogers','trish','trishtunney',

class User < ActiveRecord::Base

  include MailChimp

  named_scope :active, :conditions => ["users.state = 'active'"]
  before_destroy do |user|
    fs = Favorite.artists.find_all_by_favoritable_id( user.id )
    fs.each { |f| f.delete }
  end

  [:studionumber, :studionumber=
   ].each do |delegat|
    delegate delegat, :to => :artist_info, :allow_nil => true
  end
  
  attr_reader :fullname, :emailsettings

  cattr_reader :sort_by_firstname, :sort_by_lastname
  @@sort_by_firstname = lambda{|a,b| 
    a.lastname.downcase <=> b.lastname.downcase 
  }
  @@sort_by_lastname = lambda{|a,b| 
    a.lastname.downcase <=> b.lastname.downcase 
  }
	
  has_many :favorites do
    def to_obj
      deletia = []
      (proxy_owner.favorites.map { |f| 
         f.to_obj
       }).select { |item| !item.nil? }
    end
  end

  belongs_to :studio
  has_and_belongs_to_many :roles

  include ImageDimensions

  include Authentication
  include Authentication::ByPassword
  include Authentication::ByCookieToken
  include Authorization::StatefulRoles

  validates_presence_of     :login
  validates_length_of       :login,    :within => 5..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    :with => Authentication.login_regex, :message => Authentication.bad_login_message

  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    :with => Authentication.email_regex, :message => Authentication.bad_email_message
  validates_length_of       :firstname,:maximum => 100, :allow_nil => true
  validates_length_of       :lastname, :maximum => 100, :allow_nil => true

  # custom validations
  validate :validate_username

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :name, :password, :password_confirmation, :firstname, :lastname, :url, :reset_code, :emailsettings, :email_attrs, :studio_id, :artist_info, :state

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

  def get_profile_image(size = :medium)
    ArtistProfileImage.get_path(self, size)
  end

  def is_in_role?(role)
    if role.nil?
      return false;
    end
    return roles.include?(Role[role])
  end

  def get_share_link(urlsafe=false, options = {})
    link = 'http://%s/artists/%s' % [Conf.site_url, self.login]
    if options.present?
      link += "?" + options.map{ |k,v| "#{k}=#{v}" }.join('&')
    end
    if urlsafe
      CGI::escape(link)
    else
      link
    end
  end

  def emailsettings=(v)
    self.email_attrs = v.to_json
  end

  def emailsettings
    s = JSON.parse(email_attrs)
    if !s.has_key? 'favorites'
      s['favorites'] = true
    end
    s
  end

  def fancy_link()
    return "http://" + Conf.site_url + "/artists/" + self.login
  end

  def fullname
    fullname = nil
    if !(self.firstname.blank? or self.lastname.blank?)
      fullname = [self.firstname, self.lastname].join(" ")
    end
    fullname || self.login
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
    if !self.lastname.blank? && self.lastname[0].chr.match('[\w\d]')
      self.lastname.downcase
    elsif !self.firstname.blank? && self.firstname[0].chr.match('[\w\d]')
      self.firstname.downcase
    else
      self.login.downcase
    end
  end

  def is_admin?
    begin
      self.roles.map(&:id).include? Role.find_by_role('admin').id
    rescue Exception => e
      logger.debug(e)
      # if we have any issues, not admin
      false
    end 
  end

  def is_editor?
    begin
      self.roles.include? Role.find_by_role('editor')
    rescue Exception => e
      logger.debug(e)
      # if we have any issues, not admin
      false
    end 
  end

  def os2010?
    osend = DateTime.new(2010,04,27)
    self.artist_info.os2010 && (DateTime.now < osend)
  end

  def osoct2010?
    osend = DateTime.new(2010,10,15)
    self.artist_info.osoct2010 && (DateTime.now < osend)
  end

  def tags
    # rollup and return most popular 15 tags
    if @mytags == nil
      logger.debug("Fetching my tags")
      tags = {}
      for ap in self.art_pieces
        if ap.art_piece_tags
          ap.art_piece_tags.each do |t| 
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

  def validate_phone
    errors.add(:phone, 'is an invalid phone number, must contain at least 5 digits, only the following characters are allowed: 0-9/-()+') unless User.valid_phone?(phone)
  end

  def validate_username
    errors.add(:login, 'you requested is a reserved name.  Try a different login') unless User.valid_username?(login)
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

  def add_favorite(fav)
    # can't favorite yourself
    unless ((([Artist,User].include? fav.class) && fav.id == self.id) ||
            (fav.class == ArtPiece && fav.artist.id == self.id))
      # don't add dups
      unless Favorite.find_by_favoritable_id_and_favoritable_type_and_user_id(fav.id, fav.class.name, self.id)
        f = Favorite.new( :favoritable_type => fav.class.name, :favoritable_id => fav.id, :user_id => self.id)
        f.save!

        fan = self
        artist = (fav.class == Artist) ? fav : fav.artist
        if artist && artist.emailsettings['favorites']
          ArtistMailer.deliver_favorite_notification artist, fan
        end
      else
        false
      end
    else
      false
    end
  end

  def what_i_favorite
    # collect artist and art piece stuff
    favs = self.favorites.reverse
    result = []
    favs.each do |f|
      out = case f.favoritable_type
            when 'Artist','User','MAUFan' then
              User.find(f.favoritable_id)
            when 'ArtPiece' then
              ArtPiece.find(f.favoritable_id)
            end
      result << out unless out.nil?
    end
    result.uniq
  end

  def who_favorites_me
    favs = Favorite.users.find_all_by_favoritable_id(self.id, :order => 'created_at desc')
    if self[:type] == 'Artist'
      if self.art_pieces && self.art_pieces.count > 0
        favs << Favorite.art_pieces.find_all_by_favoritable_id( art_pieces.map{|ap| ap.id}, :order => 'created_at desc')
      end
    end
    User.find(favs.flatten.select{|f| !f.nil? && !f.user_id.nil?}.map {|f| f.user_id})
  end

  def remove_favorite(fav)
    f = favorites.select { |f| f.favoritable_type == fav.class.name && f.favoritable_id == fav.id }
    r = f.each do |f|
      f.destroy
    end
    r.first
  end

  def fav_artists
    favorites.to_obj.reverse.select { |f| [User, Artist].include? f.class }.uniq
  end

  def fav_art_pieces
    favorites.to_obj.reverse.select { |f| f.class == ArtPiece }.uniq
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

  def csv_safe(field) 
    self.send(field).gsub(/\W/, '')
  end

  def is_artist?
    self[:type] == 'Artist'
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = User.make_token
  end
  
  protected
  def get_favorite_ids(tps)
    (favorites.select{ |f| tps.include? f.favoritable_type.to_s }).map{ |f| f.favoritable_id }
  end

end
