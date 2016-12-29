require 'digest/sha1'
require 'json'

class User < ApplicationRecord

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

  store :links, accessors: %i| website facebook twitter blog pinterest myspace flickr instagram artspan |

  extend FriendlyId
  friendly_id :login, use: [:slugged]

  # custom validations
  validate :validate_email

  has_attached_file :photo, styles: MauImage::Paperclip::STANDARD_STYLES, default_url: ''

  validates_attachment_content_type :photo, content_type: /\Aimage\/.*\Z/, if: :"photo?"

  # I was initially worried about routes here - i think we should be fine moving forward
  #
  # RESTRICTED_LOGIN_NAMES = [ 'add_profile','delete','destroy','delete_art',
  #                            'deactivate','add','new','view','create','update',
  #                            'arrange_art', 'setarrangement',
  #                            'admin','root','mau', 'mauadmin','maudev',
  #                            'jon','mrrogers','trish','trishtunney' ]

  include User::Authentication
  include User::Authorization

  after_create :tell_user_they_signed_up

  scope :active, -> { where(state: 'active') }
  scope :not_active, -> { where("state <> 'active'") }
  scope :pending, -> { where(state: 'pending') }
  scope :suspended, -> { where(state: 'suspended') }
  scope :deleted, -> { where(state: 'deleted') }

  before_validation :normalize_attributes
  before_validation :add_http_to_links
  before_validation :cleanup_fields
  before_destroy :delete_favorites

  def self.admin
    joins(:roles_users).where(roles_users: { role: Role.admin } )
  end

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

  has_many :favorites, dependent: :destroy, class_name: 'Favorite' do
     def to_obj
       proxy_association.owner.favorites.map(&:to_obj).reject(&:nil?)
     end
  end

  belongs_to :studio
  has_many :roles_users, dependent: :destroy
  has_many :roles, through: :roles_users

  acts_as_authentic do |c|
    c.act_like_restful_authentication = true
    c.transition_from_restful_authentication = true
  end

  def active?
    state == 'active'
  end

  def pending?
    state == 'pending'
  end

  def get_profile_image(size = :medium)
    photo? ? photo(size) : ArtistProfileImage.get_path(self, size)
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

  def full_name
    full_name = nomdeplume if nomdeplume.present?
    if !full_name && firstname.present? && lastname.present?
      full_name = [firstname, lastname].join(" ")
    end
    full_name || self.login
  end

  def get_name(htmlsafe=false)
    return full_name unless htmlsafe
    HtmlEncoder.encode(full_name)
  end

  def sortable_name
    key = [lastname, firstname, login].join.downcase
    key.gsub(/\W/,' ').strip
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

  def delete!
    update_attribute(:state, 'deleted')
  end

  def suspend!
    self.update_attribute :state, 'suspended'
  end

  def suspended?
    self.state == 'suspended'
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

  def is_artist?
    self[:type] == 'Artist'
  end

  def manages?(studio)
    is_manager? && (self.studio == studio)
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = TokenService.generate
  end

  protected
  def cleanup_fields
    [:firstname, :lastname, :nomdeplume, :email].each do |fld|
      v = self.send(fld)
      if v.present? && v.respond_to?('strip')
        self.send("#{fld}=", v.strip)
      end
    end
  end

  def normalize_attributes
    login = login.try(:downcase)
    email = email.try(:downcase)
  end

  def tell_user_they_signed_up
    if is_artist?
      reload
      ArtistMailer.signup_notification(self).deliver_later
    end
  end

  def notify_user_about_state_change
    mailer_class = is_artist? ? ArtistMailer : UserMailer
    reload
    if recently_activated? && mailchimp_subscribed_at.nil?
      mailer_class.activation(self).deliver_later
      FeaturedArtistQueue.create(artist_id: id, position: rand) if is_artist?
    end
    mailer_class.reset_notification(self).deliver_later if recently_reset?
    mailer_class.resend_activation(self).deliver_later if resent_activation?
  end

  def _add_http_to_link(link)
    if link.present?
      (/^https?:\/\// =~ link) ? link : ('http://' + link)
    end
  end

  def add_http_to_links
    if url.present?
      self.url = _add_http_to_link(url)
    end
    User.stored_attributes[:links].each do |site|
      self.send("#{site}=", _add_http_to_link(self.send(site)))
    end
  end
end
