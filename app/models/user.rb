# == Schema Information
#
# Table name: users
#
#  id                        :integer          not null, primary key
#  login                     :string(40)
#  name                      :string(100)      default("")
#  email                     :string(100)
#  crypted_password          :string(40)
#  salt                      :string(40)
#  created_at                :datetime
#  updated_at                :datetime
#  remember_token            :string(40)
#  remember_token_expires_at :datetime
#  firstname                 :string(40)
#  lastname                  :string(40)
#  nomdeplume                :string(80)
#  phone                     :string(16)
#  url                       :string(200)
#  profile_image             :string(200)
#  studio_id                 :integer
#  facebook                  :string(200)
#  twitter                   :string(200)
#  blog                      :string(200)
#  myspace                   :string(200)
#  flickr                    :string(200)
#  activation_code           :string(40)
#  activated_at              :datetime
#  state                     :string(255)      default("passive")
#  deleted_at                :datetime
#  reset_code                :string(40)
#  image_height              :integer          default(0)
#  image_width               :integer          default(0)
#  max_pieces                :integer          default(20)
#  email_attrs               :string(255)      default("{\"fromartist\": true, \"favorites\": true, \"fromall\": true}")
#  studionumber              :string(255)
#  type                      :string(255)      default("Artist")
#  mailchimp_subscribed_at   :date
#
# Indexes
#
#  index_artists_on_login    (login) UNIQUE
#  index_users_on_studio_id  (studio_id)
#

require 'digest/sha1'
require 'json'
require File.join(Rails.root, 'app','lib', 'mailchimp')

RESTRICTED_LOGIN_NAMES = [ 'add_profile','delete','destroy','deleteart',
                           'deactivate','add','new','view','create','update',
                         'arrangeart', 'setarrangement']

# here are names we should probably capture or disallow before we release
# the site.  maybe we make a migration to create these accounts
#'admin','root','mau', 'mauadmin','maudev',
#'jon','mrrogers','trish','trishtunney',

class User < ActiveRecord::Base

  include MailChimp
  include HtmlHelper

  after_create :tell_user_they_signed_up
  after_save :notify_user_about_state_change

  scope :active, where(:state => 'active')
  scope :pending, where(:state => 'pending')

  before_destroy :delete_favorites
  def delete_favorites
    fs = Favorite.artists.where(:favoritable_id => id)
    fs.each(&:delete)
  end

  [:studionumber, :studionumber=
   ].each do |delegat|
    delegate delegat, :to => :artist_info, :allow_nil => true
  end

  SORT_BY_LASTNAME = lambda{|a,b|
    a.lastname.downcase <=> b.lastname.downcase
  }

  has_many :favorites, :class_name => 'Favorite' do
     def to_obj
       # rails 3.1
       # you'll need this
       # http://stackoverflow.com/questions/7001810/alternative-method-for-proxy-owner-in-activerecord

       # < Rails 3.0
       # (proxy_owner.favorites.map { |f|
       #    f.to_obj
       #  }).reject(&:nil?)

       proxy_association.owner.favorites.map(&:to_obj).reject(&:nil?)
     end
  end

  belongs_to :studio
  has_many :roles_users, :dependent => :destroy
  has_many :roles, :through => :roles_users

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
  validate :validate_email

  attr_accessible :login, :email, :name, :password, :password_confirmation,
   :firstname, :lastname, :url, :reset_code, :email_attrs, :studio_id, :artist_info, :state, :nomdeplume,
   :profile_image, :image_height, :image_width


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

  def active?
    state == 'active'
  end

  def has_profile_image
    self.profile_image
  end

  def get_profile_image(size = :medium)
    ArtistProfileImage.get_path(self, size)
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

  def fullname
    fullname = nil
    if nomdeplume.present?
      fullname = nomdeplume
    elsif firstname.present? && lastname.present?
      fullname = [firstname, lastname].join(" ")
    end
    fullname || self.login
  end

  def get_name(htmlsafe=false)
    name = self.fullname
    if not name
      name = self.login
    end
    if htmlsafe
      html_encode(name)
    else
      name
    end
  end

  def get_sort_name
    # get name for sorting:  try lastname, then firstname then login
    word_num_regex = %r|^[\w\d]|
    if word_num_regex =~ (lastname ||'')
      lastname.downcase
    elsif word_num_regex =~ (firstname || '')
      firstname.downcase
    else
      login.downcase
    end
  end
  alias_method :sortable_name, :get_sort_name

  def is_active?
    state == 'active'
  end

  def is_special?
    is_admin? || is_manager? || is_editor?
  end

  def is_admin?
    begin
      roles.map(&:id).include? Role.admin.id
    rescue Exception => e
      logger.debug(e)
      false
    end
  end

  def is_manager?
    begin
      is_admin? || (roles.include? Role.manager)
    rescue Exception => e
      logger.debug(e)
      false
    end
  end

  def is_editor?
    begin
      is_admin? || (roles.include? Role.editor)
    rescue Exception => e
      logger.debug(e)
      false
    end
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
    @mymedia ||= art_pieces.map(&:medium).compact.uniq
  end

  def validate_phone
    errors.add(:phone, 'is an invalid phone number, must contain at least 5 digits,'+
               ' only the following characters are allowed: 0-9/-()+') unless User.valid_phone?(phone)
  end

  def validate_email
    errors.add(:email, 'is an invalid email') unless BlacklistDomain::is_allowed?(email)
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
    save(:validate => false)
  end

  def resent_activation?
    @resent_activation
  end

  def create_reset_code
    @reset = true
    self.attributes = {:reset_code => Digest::SHA1.hexdigest( Time.zone.now.to_s.split(//).sort_by {rand}.join )}
    save(:validate => false)
  end

  def recently_reset?
    @reset
  end

  def delete_reset_code
    self.attributes = {:reset_code => nil}
    save(:validate => false)
  end

  def suspended?
    self.state == 'suspended'
  end

  def add_favorite(fav)
    # can't favorite yourself
    unless (!fav.nil? && ((([Artist,User].include? fav.class) && fav.id == self.id) ||
            (fav.class == ArtPiece && fav.artist.id == self.id)))
      # don't add dups
      unless Favorite.find_by_favoritable_id_and_favoritable_type_and_user_id(fav.id, fav.class.name, self.id)
        f = Favorite.new( :favoritable_type => fav.class.name, :favoritable_id => fav.id, :user_id => self.id)
        f.save!

        fan = self
        artist = (fav.class == Artist) ? fav : fav.artist
        if artist && artist.emailsettings['favorites']
          ArtistMailer.favorite_notification(artist, fan).deliver!
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
    favs = Favorite.users.where(:favoritable_id => self.id).order('created_at desc')
    if self[:type] == 'Artist'
      if self.art_pieces && self.art_pieces.count > 0
        favs << Favorite.art_pieces.where(:favoritable_id => art_pieces.map{|ap| ap.id}).order('created_at desc')
      end
    end
    User.find(favs.flatten.select{|f| !f.nil? && !f.user_id.nil?}.map {|f| f.user_id})
  end

  def remove_favorite(fav)
    f = self.favorites.select { |f| (f.favoritable_type == fav.class.name) && (f.favoritable_id == fav.id) }
    f.map(&:destroy).first
  end

  def fav_artists
    favorites.to_obj.reverse.select { |f| [User, Artist].include? f.class }.uniq
  end

  def fav_art_pieces
    favorites.to_obj.reverse.select { |f| f.class == ArtPiece }.uniq
  end

  # reformat data so that the artist contains the art pieces
  # and that any security related data is missing (salt, password etc)
  def clean_for_export(art_pieces)
    retval = { "artist" => {}, "artpieces" => [] }
    keys = [ 'firstname','lastname','login', 'street' ]
    keys.each do |k|
      retval["artist"][k] = self.send(k)
    end
    apkeys = ['title','filename']
    retval['artpieces'] = (art_pieces||[]).map do |ap|
      Hash[apkeys.map{|k| [k,ap.send(k)]}]
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

  def uniqify_roles
    self.roles = roles.uniq{|r| r.id}
  end

  protected
  def get_favorite_ids(tps)
    (favorites.select{ |f| tps.include? f.favoritable_type.to_s }).map{ |f| f.favoritable_id }
  end

  def tell_user_they_signed_up
    if is_artist?
      reload
      ArtistMailer.signup_notification(self).deliver!
    end
  end

  def notify_user_about_state_change
    mailer_class = is_artist? ? ArtistMailer : UserMailer
    reload
    if recently_activated? && mailchimp_subscribed_at.nil?
      mailer_class.activation(self).deliver!
      FeaturedArtistQueue.create(:artist_id => id, :position => rand) if is_artist?
    end
    mailer_class.reset_notification(self).deliver! if recently_reset?
    mailer_class.resend_activation(self).deliver! if resent_activation?
  end

end
