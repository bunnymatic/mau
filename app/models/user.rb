# frozen_string_literal: true

require 'digest/sha1'
require 'json'
require Rails.root.join('lib', 'authlogic', 'crypto_providers', 'restful_auth_sha1.rb')
require Rails.root.join('lib', 'authlogic', 'crypto_providers', 'restful_auth_scrypt.rb')

class User < ApplicationRecord
  validates :login, presence: true
  validates :login, length: { within: 5..40 }
  validates :login, uniqueness: true
  validates :login, format: { with: Mau::Regex::LOGIN, message: Mau::Regex::BAD_LOGIN_MESSAGE }

  validates :email, presence: true
  validates :email, length: { within: 6..100 } # r@a.wk
  validates :email, uniqueness: true
  validates :email, format: { with: Mau::Regex::EMAIL, message: Mau::Regex::BAD_EMAIL_MESSAGE }
  validates :firstname, length: { maximum: 100, allow_nil: true }
  validates :lastname, length: { maximum: 100, allow_nil: true }

  validates :password,
            confirmation: { if: :require_password? },
            length: {
              minimum: 8,
              if: :require_password?
            }
  validates :password_confirmation,
            length: {
              minimum: 8,
              if: :require_password?
            }

  store :links, accessors: %i[website facebook twitter blog pinterest myspace flickr instagram artspan]

  attr_accessor :password_confirmation

  extend FriendlyId
  friendly_id :login, use: [:slugged]

  # custom validations
  validate :validate_email

  has_attached_file :photo, styles: MauImage::Paperclip::STANDARD_STYLES, default_url: ''

  validates_attachment_content_type :photo, content_type: %r{\Aimage\/.*\Z}, if: :"photo?"

  # I was initially worried about routes here - i think we should be fine moving forward
  #
  # RESTRICTED_LOGIN_NAMES = [ 'add_profile','delete','destroy','delete_art',
  #                            'deactivate','add','new','view','create','update',
  #                            'arrange_art', 'setarrangement',
  #                            'admin','root','mau', 'mauadmin','maudev',
  #                            'jon','mrrogers','trish','trishtunney' ]

  include User::Authentication
  include User::Authorization

  scope :fan, -> { where.not(type: 'Artist') }
  scope :active, -> { where(state: :active) }
  scope :not_active, -> { where.not(state: :active) }
  scope :pending, -> { where(state: :pending) }
  scope :suspended, -> { where(state: :suspended) }
  scope :deleted, -> { where(state: :deleted) }
  scope :admin, -> { joins(:roles_users).where(roles_users: { role: Role.admin }) }

  scope :bad_standing, -> { where(state: %i[suspended deleted]) }

  before_validation :normalize_attributes
  before_validation :add_http_to_links
  before_validation :cleanup_fields
  before_destroy :delete_favorites

  def mailchimp_subscribed?
    !!mailchimp_subscribed_at
  end

  def self.login_or_email_finder(login)
    find_by(login: login) || find_by(email: login)
  end

  def delete_favorites
    Favorite.artists.where(favoritable_id: id).delete_all
  end

  %i[studionumber studionumber=].each do |delegat|
    delegate delegat, to: :artist_info, allow_nil: true
  end

  SORT_BY_LASTNAME = lambda do |a, b|
    a.lastname.downcase <=> b.lastname.downcase
  end

  has_many :favorites, dependent: :destroy, inverse_of: :user, class_name: 'Favorite'

  belongs_to :studio
  has_many :roles_users
  has_many :roles, through: :roles_users, dependent: :destroy

  acts_as_authentic do |c|
    c.transition_from_crypto_providers = [
      Authlogic::CryptoProviders::Sha1,
      Authlogic::CryptoProviders::RestfulAuthSha1,
      Authlogic::CryptoProviders::RestfulAuthSCrypt
    ]
    c.crypto_provider = Authlogic::CryptoProviders::SCrypt
    c.require_password_confirmation = true
  end

  def active?
    state == 'active'
  end

  def pending?
    state == 'pending'
  end

  def get_profile_image(size = :medium)
    photo(size) if photo?
  end

  def full_name
    full_name = nomdeplume if nomdeplume.present?
    full_name = [firstname, lastname].join(' ') if !full_name && firstname.present? && lastname.present?
    full_name || login
  end

  def get_name(htmlsafe = false)
    return full_name unless htmlsafe

    HtmlEncoder.encode(full_name)
  end

  def sortable_name
    key = [lastname, firstname, login].join.downcase
    key.gsub(/\W/, ' ').strip
  end

  def validate_email
    errors.add(:email, 'is an invalid email') unless BlacklistDomain.allowed?(email)
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
    self.attributes = { reset_code: Digest::SHA1.hexdigest(Time.zone.now.to_s.split(//).sort_by { rand }.join) }
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
    self.attributes = { reset_code: nil }
    save(validate: false)
  end

  def delete!
    update(state: 'deleted', activation_code: nil, reset_code: nil)
  end

  def suspend!
    update(state: 'suspended', activation_code: nil, reset_code: nil)
  end

  def suspended?
    state == 'suspended'
  end

  def fav_artists
    @fav_artists ||= favorites.artists.by_recency.distinct.compact
  end

  def fav_art_pieces
    @fav_art_pieces ||= favorites.art_pieces.by_recency.distinct.compact
  end

  def artist?
    self[:type] == 'Artist'
  end

  def manages?(studio)
    admin? || manager? && (self.studio == studio)
  end

  def make_activation_code
    self.deleted_at = nil
    self.activation_code = TokenService.generate
  end

  protected

  def cleanup_fields
    %i[firstname lastname nomdeplume email].each do |fld|
      v = send(fld)
      send("#{fld}=", v.strip) if v.present? && v.respond_to?('strip')
    end
  end

  def normalize_attributes
    self.login = login.try(:downcase)
    self.email = email.try(:downcase)
  end

  def notify_user_about_state_change
    mailer_class = artist? ? ArtistMailer : UserMailer
    reload
    mailer_class.activation(self).deliver_later if recently_activated? && mailchimp_subscribed_at.nil?
    mailer_class.reset_notification(self).deliver_later if recently_reset?
    mailer_class.resend_activation(self).deliver_later if resent_activation?
  end

  def _add_http_to_link(link)
    return if link.blank?

    %r{^https?:\/\/}.match?(link) ? link : ('http://' + link)
  end

  def add_http_to_links
    self.url = _add_http_to_link(url) if url.present?
    User.stored_attributes[:links].each do |site|
      send("#{site}=", _add_http_to_link(send(site))) if send(site).present?
    end
  end
end
