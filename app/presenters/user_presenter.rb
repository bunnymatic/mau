# This presenter adds helpful display/view related methods
# to make it easy to draw user data on a page

class UserPresenter < ViewPresenter

  ALLOWED_FAVORITE_CLASSES = [Artist, MauFan, User].map(&:name)
  ALLOWED_LINKS = [:website]
  attr_accessor :model

  delegate :name, :state, :firstname, :lastname, :nomdeplume, :city, :street, :id,
           :bio, :address, :address_hash, :get_name,
           :facebook, :twitter, :instagram,
           :login, :active?,
           :activated_at, :email, :last_login, :full_name,
           :to_param,
           to: :model, allow_nil: true

  def initialize(user)
    @model = user
  end

  def icon_for_state
    icon_class = {
      active: "check-circle-o",
      pending: "clock-o",
      deleted: "times-circle-o",
      suspended: "thumbs-o-down"
    }[state.to_sym]
    "fa fa-#{icon_class}" if icon_class
  end

  def member_since
    (model.activated_at || model.created_at).strftime "%b %Y"
  end

  def last_login
    model.last_login_at.try(:to_formatted_s,:admin)
  end

  def activation_date
    model.activated_at.try(:to_formatted_s,:admin_date_only)
  end

  def doing_open_studios?
    false
  end

  def who_i_favorite
    # collect artist and art piece stuff
    @who_i_favorite ||=
      begin
        user_favorites, art_piece_favorites = model.favorites.partition do |fav|
          ALLOWED_FAVORITE_CLASSES.include? fav.favoritable_type
        end
        art_pieces = ArtPiece.includes(:artist).owned.where(id: art_piece_favorites.map(&:favoritable_id) ).map(&:artist)
        users = Artist.active.where(id: user_favorites.map(&:favoritable_id))

        [ users, art_pieces ].flatten.compact.uniq
      end
  end

  def who_favorites_me
    @who_favorites_me ||=
      begin
        favs = favorites_of_me.flatten
        user_ids = favs.map(&:user_id).compact.uniq
        User.active.where(id: user_ids)
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
        match = /facebook.com\/(.*)/.match(model.facebook.to_s)
        match.captures.first if match
      end
  end

  def instagram_handle
    @instagram_handle ||=
      begin
        match = /instagram.com\/(.*)/.match(model.instagram.to_s)
        match.captures.first if match
      end
  end

  def twitter_handle
    @twitter_handle ||=
      begin
        match = /twitter.com\/(.*)/.match(model.twitter.to_s)
        match.captures.first if match
      end
  end

  def favorites_of_me
    @favorites_of_me ||= Favorite.users.where(favoritable_id: self.id).order('created_at desc')
  end

  def valid?
    !model.nil?
  end

  def created_at
    model.created_at.strftime("%m/%d/%y")
  end

  def activation_state
    model.activated_at ? model.activated_at.strftime("%m/%d/%y") : model.state
  end

  def has_activation_code?
    model.state != 'active' && model.activation_code.present?
  end

  def has_reset_code?
    model.reset_code.present?
  end

  def activation_link
    url_helpers.activate_url(model.activation_code)
  end

  def reset_password_link
    url_helpers.reset_url(model.reset_code )
  end

  def has_links?
    @has_links ||= links.any?
  end

  def links
    @links ||= self.class.keyed_links.map do |kk|
      v = @model.send(kk)
    end.compact
  end

  def links_html
    self.class.keyed_links.map do |key|
      site = @model.send(key)
      if site.present?
        formatted_site = format_link(site)
        site_display = format_link_for_display(site)
        link_icon_class = icon_link_class(key, site)
        content_tag 'a', href: formatted_site, title: display, target: '_blank' do
          content_tag(:i,'', class: link_icon_class) +
            content_tag(:span,site_display)
        end
      end
    end.compact
  end

  def has_profile_image?
    model.photo? || model.profile_image.present?
  end

  def profile_image(size = small)
    model.photo? ? model.photo(size) : (model.profile_image.present? ? model.get_profile_image(size) : nil)
  end

  alias_method :get_profile_image, :profile_image

  private
  def format_link_for_display(link)
    strip_http_from_link(link)
  end

  def format_link(link)
    if link.present?
      (/^https?:\/\//.match(link) ? link : "http://#{link}")
    end
  end

  def icon_link_class(key, site)
    site = strip_http_from_link(site)
    clz = [:ico, "ico-invert", "ico-#{key}"]
    icon_chooser = begin
                     if site =~ /\.tumblr\./
                       "ico-tumblr"
                     elsif key.to_sym == :blog
                       if site =~ /\.blogger\./
                         "ico-blogger"
                       else
                         site_bits = site.split(".")
                         "ico-" + ((site_bits.length > 2) ? site_bits[-3] : site_bits[0])
                       end
                     end
                   end
    (clz + [icon_chooser]).join(' ')
  end

  def strip_http_from_link(link)
    link.gsub /^https?:\/\//, ''
  end

  def self.keyed_links
    (User.stored_attributes[:links] || []).select { |attr| ALLOWED_LINKS.include? attr }
  end


end
