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
      active: 'star',
      pending: 'question-circle',
      deleted: 'times-circle',
      suspended: 'user-times',
    }[state.to_sym]
    "fa fa-#{icon_class}" if icon_class
  end

  def member_since_date
    model.activated_at || model.created_at
  end

  def member_since
    member_since_date.strftime '%b %Y'
  end

  def last_updated_at
    model.updated_at
  end

  def last_login_at
    Time.use_zone(Conf.event_time_zone) do
      model.last_request_at || model.current_login_at || model.last_login_at
    end
  end

  def last_login
    last_login_at.try(:to_formatted_s, :admin)
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
      # Because of STI issues we can't do `favoritable: model` - already tried
      Favorite.where(favoritable_type: model.class.name, favoritable_id: model.id)
              .merge(Favorite.active_owners)
              .order(created_at: :desc)
              .distinct(:owner)
              .map(&:owner).flatten
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
    model.state != Constants::User::STATE_ACTIVE && model.activation_code.present?
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
    @links ||= keyed_links.values
  end

  def keyed_links
    @model.links.compact_blank
  end

  def links_html
    keyed_links.filter_map do |key, site|
      formatted_site = format_link(site)
      site_display = format_link_for_display(site)
      link_icon_class = self.class.icon_link_class(key, site)
      tag.a(href: formatted_site, title: site_display, target: '_blank') do
        tag.i('', class: link_icon_class)
      end
    end
  end

  delegate :profile_image?, to: :model

  def profile_image(size = :small)
    model.profile_image(size)
  end

  def self.keyed_links
    (User.stored_attributes[:links] || []).select { |attr| ALLOWED_LINKS.include? attr }
  end

  KNOWN_SOCIAL_ICONS = %i[blog blogger pinterest myspace instagram facebook twitter flickr].freeze
  def self.icon_link_class(key, site = '')
    site = strip_http_from_link(site)
    key = 'star-alt' unless KNOWN_SOCIAL_ICONS.include?(key.to_sym)
    clz = [:fa, 'fa-ico-invert', "fa-#{key}"]
    icon_chooser = choose_icon_from_site(site, key) || ''

    (clz + [icon_chooser]).join(' ')
  end

  private

  class << self
    def choose_icon_from_site(site, key)
      if site.include?('.tumblr.')
        'fa-tumblr'
      elsif %i[blog blogger].include?(key.to_sym)
        if site.include?('.blogger.')
          'fa-blogger'
        elsif site.present?
          site_bits = site.split('.')
          "fa-star-alt fa-#{site_bits.length > 2 ? site_bits[-3] : site_bits[0]}"
        else
          'fa-star-alt'
        end
      end
    end

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
