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
#  pinterest                 :string(255)
#  instagram                 :string(255)
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

require 'digest/sha1'
require 'json'
require File.join(Rails.root, 'app','lib', 'mailchimp')

class User < ActiveRecord::Base

  validates_presence_of     :login
  validates_length_of       :login,    within: 5..40
  validates_uniqueness_of   :login
  validates_format_of       :login,    with: Mau::Regex::LOGIN, message: Mau::Regex::BAD_LOGIN_MESSAGE

  validates_presence_of     :email
  validates_length_of       :email,    within: 6..100 #r@a.wk
  validates_uniqueness_of   :email
  validates_format_of       :email,    with: Mau::Regex::EMAIL, message: Mau::Regex::BAD_EMAIL_MESSAGE
  validates_length_of       :firstname,maximum: 100, allow_nil: true
  validates_length_of       :lastname, maximum: 100, allow_nil: true

  # custom validations
  validate :validate_email

  # I was initially worried about routes here - i think we should be fine moving forward
  #
  # RESTRICTED_LOGIN_NAMES = [ 'add_profile','delete','destroy','delete_art',
  #                            'deactivate','add','new','view','create','update',
  #                            'arrange_art', 'setarrangement',
  #                            'admin','root','mau', 'mauadmin','maudev',
  #                            'jon','mrrogers','trish','trishtunney' ]

  include MailChimp
  include HtmlHelper
  include User::Authentication
  include User::Authorization

  after_create :tell_user_they_signed_up

  scope :active, where(state: 'active')
  scope :not_active, where("state <> 'active'")
  scope :pending, where(state: 'pending')

  def self.find_by_username_or_email(login_string)
    User.find_by_login(login_string) || User.find_by_email(login_string)
  end

  before_validation :normalize_attributes
  before_validation :add_http_to_links
  before_destroy :delete_favorites

  def self.find_by_login_or_email(login)
    find_by_email(login) || find_by_login(login)
  end

  def delete_favorites
    fs = Favorite.artists.where(favoritable_id: id)
    fs.each(&:delete)
  end

  [:studionumber, :studionumber= ].each do |delegat|
    delegate delegat, to: :artist_info, allow_nil: true
  end

  SORT_BY_LASTNAME = lambda{|a,b|
    a.lastname.downcase <=> b.lastname.downcase
  }

  has_many :favorites, class_name: 'Favorite' do
     def to_obj
       proxy_association.owner.favorites.map(&:to_obj).reject(&:nil?)
     end
  end

  belongs_to :studio
  has_many :roles_users, dependent: :destroy
  has_many :roles, through: :roles_users, dependent: :destroy

  include ImageDimensions

  acts_as_authentic do |c|
    c.act_like_restful_authentication = true
    c.transition_from_restful_authentication = true
  end

  attr_accessible :login, :email, :password, :password_confirmation,
   :firstname, :lastname, :url, :reset_code, :email_attrs, :studio_id, :artist_info, :state, :nomdeplume,
   :profile_image, :image_height, :image_width

  def active?
    state == 'active'
  end

  def pending?
    state == 'pending'
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
    urlsafe ? CGI::escape(link) : link
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
    fullname = nomdeplume if nomdeplume.present?
    if !fullname && firstname.present? && lastname.present?
      fullname = [firstname, lastname].join(" ")
    end
    fullname || self.login
  end

  alias_method :full_name, :fullname

  def get_name(htmlsafe=false)
    name = full_name || login
    htmlsafe ? html_encode(name) : name
  end

  def sortable_name
    key = [lastname, firstname, login].join.downcase
    key.gsub(%r|\W|,' ').strip
  end

  def is_active?
    state == 'active'
  end

  def delete!
    update_attribute(:state, 'deleted')
  end

  def tags
    # rollup and return most popular 15 tags
    @mytags ||= art_pieces.map(&:tags).flatten.compact.uniq
  end

  def media
    @mymedia ||= art_pieces.map(&:medium).flatten.compact.uniq
  end

  def validate_email
    errors.add(:email, 'is an invalid email') unless BlacklistDomain::is_allowed?(email)
  end


  def resend_activation
    @resent_activation = true
    make_activation_code
    save(validate: false)
    notify_user_about_state_change
  end

  def resent_activation?
    @resent_activation
  end

  def create_reset_code
    @reset = true
    self.attributes = {reset_code: Digest::SHA1.hexdigest( Time.zone.now.to_s.split(//).sort_by {rand}.join )}
    save(validate: false)
    notify_user_about_state_change
  end

  def recently_activated?
    activated_at && ((Time.zone.now - activated_at) < 10.seconds)
  end

  def recently_reset?
    @reset
  end

  def delete_reset_code
    self.attributes = {reset_code: nil}
    save(validate: false)
  end

  def suspend!
    self.update_attribute :state, 'suspended'
  end

  def suspended?
    self.state == 'suspended'
  end

  def add_favorite(fav)
    # can't favorite yourself
    unless trying_to_favorite_yourself?(fav)
      # don't add dups
      favorite_params = {
        favoritable_type: fav.class.name,
        favoritable_id: fav.id,
        user_id: self.id
      }
      if Favorite.where(favorite_params).limit(1).blank?
        Favorite.create!(favorite_params)
        notify_favorited_user(fav)
      end
    end
  end

  def notify_favorited_user(fav)
    artist = (fav.is_a? User) ? fav : fav.artist
    if artist && artist.emailsettings['favorites']
      ArtistMailer.favorite_notification(artist, self).deliver!
    end
  end

  def remove_favorite(fav)
    f = self.favorites.select { |f| (f.favoritable_type == fav.class.name) && (f.favoritable_id == fav.id) }
    f.map(&:destroy).first
  end

  def favorites_to_obj
    @favorites_to_obj ||= favorites.to_obj.reverse
  end

  def fav_artists
    @fav_artists ||= favorites_to_obj.select { |f| f.is_a? User }.uniq
  end

  def fav_art_pieces
    @fav_art_pieces ||= favorites_to_obj.select { |f| f.is_a? ArtPiece }.uniq
  end



  # reformat data so that the artist contains the art pieces
  # and that any security related data is missing (salt, password etc)
  # def clean_for_export(art_pieces)
  #   retval = { "artist" => {}, "artpieces" => [] }
  #   keys = [ 'id', 'firstname','lastname','login', 'street' ]
  #   keys.each do |k|
  #     retval["artist"][k] = self.send(k)
  #   end
  #   apkeys = ['title','filename', 'id']
  #   retval['artpieces'] = (art_pieces||[]).map do |ap|
  #     Hash[apkeys.map{|k| [k,ap.send(k)]}]
  #   end
  #   retval
  # end

  def csv_safe(field)
    (self.send(field) || '').gsub(/\W/, '')
  end

  def is_artist?
    self[:type] == 'Artist'
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = TokenService.generate
  end

  def uniqify_roles
    self.roles = roles.uniq.compact
  end

  protected
  def normalize_attributes
    login = login.try(:downcase)
    email = email.try(:downcase)
  end

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
      FeaturedArtistQueue.create(artist_id: id, position: rand) if is_artist?
    end
    mailer_class.reset_notification(self).deliver! if recently_reset?
    mailer_class.resend_activation(self).deliver! if resent_activation?
  end

  def trying_to_favorite_yourself?(fav)
    false if fav.nil?
    ((fav.is_a?(User) || fav.is_a?(Artist)) && fav.id == id) || (fav.is_a?(ArtPiece) && fav.artist.id == id)
  end

  def add_http_to_links
    if url.present?
      self.url = ('http://' + url) unless /^https?:\/\// =~ url
    end
  end
end
