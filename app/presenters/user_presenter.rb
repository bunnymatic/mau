# frozen_string_literal: true

# This presenter adds helpful display/view related methods
# to make it easy to draw user data on a page

class UserPresenter < ViewPresenter
  ALLOWED_FAVORITE_CLASSES = [Artist, MauFan, User].map(&:name)
  ALLOWED_LINKS = [:website].freeze
  attr_accessor :model

  delegate :activated_at,
           :active?,
           :address,
           :bio,
           :city,
           :email,
           :facebook,
           :firstname,
           :full_name,
           :get_name,
           :id,
           :instagram,
           :last_login,
           :lastname,
           :login,
           :name,
           :nomdeplume,
           :state,
           :street,
           :to_param,
           :twitter,
           :website,
           to: :model,
           allow_nil: true

  def initialize(user)
    super()
    @model = user
  end

  def icon_for_state
    icon_class = {
      active: 'check-circle',
      pending: 'clock',
      deleted: 'times-circle',
      suspended: 'thumbs-down',
    }[state.to_sym]
    "far fa-#{icon_class}" if icon_class
  end

  def member_since_date
    (model.activated_at || model.created_at)
  end

  def member_since
    member_since_date.strftime '%b %Y'
  end

  def last_login
    (model.last_request_at || model.current_login_at || model.last_login_at).try(:to_formatted_s, :admin)
  end

  def activation_date
    model.activated_at.try(:to_formatted_s, :admin_date_only)
  end

  def doing_open_studios?
    false
  end

  def who_i_favorite
    # collect artist and art piece stuff
    @who_i_favorite ||= [my_favorite_users, my_favorite_art].flatten.compact.uniq
  end

  def who_favorites_me
    @who_favorites_me ||=
      begin
        Favorite.where(favoritable_type: model.class.name, favoritable_id: model.id)
                .includes(:owner)
                .order('created_at desc')
                .distinct(:owner)
                .map(&:owner).flatten
      end
  end

  def facebook?
    facebook_handle.present?
  end

  def instagram?
    instagram_handle.present?
  end

  def twitter?
    twitter_handle.present?
  end

  def facebook_handle
    @facebook_handle ||=
      begin
        match = %r{facebook.com/(.*)}.match(model.facebook.to_s)
        match&.captures&.first
      end
  end

  def instagram_handle
    @instagram_handle ||=
      begin
        match = %r{instagram.com/(.*)}.match(model.instagram.to_s)
        match&.captures&.first
      end
  end

  def twitter_handle
    @twitter_handle ||=
      begin
        match = %r{twitter.com/(.*)}.match(model.twitter.to_s)
        match&.captures&.first
      end
  end

  def valid?
    !model.nil?
  end

  def created_at
    model.created_at.strftime('%m/%d/%y')
  end

  def activation_state
    model.activated_at ? model.activated_at.strftime('%m/%d/%y') : model.state
  end

  def activation_code?
    model.state != 'active' && model.activation_code.present?
  end

  def reset_code?
    model.reset_code.present?
  end

  def activation_link
    url_helpers.activate_url(model.activation_code)
  end

  def reset_password_link
    url_helpers.reset_url(model.reset_code)
  end

  def links?
    links.any?
  end

  def links
    @links ||= self.class.keyed_links.map do |kk|
      @model.send(kk)
    end.compact
  end

  def links_html
    self.class.keyed_links.map do |key|
      site = @model.send(key)
      next if site.blank?

      formatted_site = format_link(site)
      site_display = format_link_for_display(site)
      link_icon_class = self.class.icon_link_class(key, site)
      tag.a(href: formatted_site, title: site_display, target: '_blank') do
        tag.i('', class: link_icon_class)
      end
    end.compact
  end

  def profile_image?
    model.photo?
  end

  def profile_image(size = small)
    model.photo(size) if model.photo?
  end

  alias get_profile_image profile_image

  def self.keyed_links
    (User.stored_attributes[:links] || []).select { |attr| ALLOWED_LINKS.include? attr }
  end

  def self.icon_link_class(key, site = '')
    site = strip_http_from_link(site)
    clz = [:ico, 'ico-invert', "ico-#{key}"]
    icon_chooser = begin
      if /\.tumblr\./.match?(site)
        'ico-tumblr'
      elsif key.to_sym == :blog
        if /\.blogger\./.match?(site)
          'ico-blogger'
        elsif !site.empty?
          site_bits = site.split('.')
          "ico-#{site_bits.length > 2 ? site_bits[-3] : site_bits[0]}"
        end
      else
        ''
      end
    end
    (clz + [icon_chooser]).join(' ')
  end

  private

  class << self
    def strip_http_from_link(link)
      link.gsub %r{^https?://}, ''
    end
  end

  def my_favorites
    if !@user_favorites || !@art_piece_favorites
      @user_favorites, @art_piece_favorites = model.favorites.partition do |fav|
        ALLOWED_FAVORITE_CLASSES.include? fav.favoritable_type
      end
    end
    { users: @user_favorites, art_pieces: @art_piece_favorites }
  end

  def my_favorite_users
    Artist.active.where(id: my_favorites[:users].map(&:favoritable_id))
  end

  def my_favorite_art
    ArtPiece.includes(:artist).owned.where(id: my_favorites[:art_pieces].map(&:favoritable_id)).map(&:artist)
  end

  def format_link_for_display(link)
    self.class.strip_http_from_link(link)
  end

  def format_link(link)
    (%r{^https?://}.match?(link) ? link : "http://#{link}") if link.present?
  end
end
