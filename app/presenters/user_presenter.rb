# This presenter adds helpful display/view related methods
# to make it easy to draw user data on a page

class UserPresenter < ViewPresenter

  attr_accessor :model

  delegate :name, :state, :firstname, :lastname, :nomdeplume, :city, :street, :id,
    :bio, :address, :address_hash, :get_name,
    :login, :active?,
    :activated_at, :email, :last_login, :full_name,
    :to_param,
    to: :model, allow_nil: true

  def initialize(user)
    @model = user
  end

  def last_login
    model.last_login_at.try(:to_formatted_s,:admin)
  end

  def doing_open_studios?
    false
  end

  def what_i_favorite
    # collect artist and art piece stuff
    @what_i_favorite ||=
      begin
        user_favorites, art_piece_favorites = model.favorites.partition do |fav|
          ['Artist', 'User', 'MAUFan'].include? fav.favoritable_type
        end

        [User.find(user_favorites.map(&:favoritable_id)),
         ArtPiece.find(art_piece_favorites.map(&:favoritable_id))].flatten.compact.uniq
      end
  end

  def who_favorites_me
    @who_favorites_me ||=
      begin
        favs = favorites_of_me.flatten
        User.find(favs.select{|f| f.try(:user_id)}.compact.uniq.map(&:user_id))
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
    @has_links ||= links.present?
  end

  def links
    @links ||= self.class.keyed_links.map do |kk, disp, _id|
      lnk = format_link(@model.send(kk))
      [_id, disp, lnk] if lnk.present?
    end.compact
  end

  def links_html
    self.class.keyed_links.map do |key, display, _id|
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

  # def show_path
  #   url_helpers.user_path(model)
  # end

  # def edit_path(opts = nil)
  #   opts ||= {}
  #   edit_user_path(model, opts)
  # end

  # def favorites_path(opts = nil)
  #   url_helpers.user_favorites_path(model)
  # end

  def has_profile_image
    model.profile_image?
  end

  def profile_image(size = small)
    if has_profile_image
      model.get_profile_image(size)
    else
      "/images/default-model.png"
    end
  end
  alias_method :get_profile_image, :profile_image

  private
  def format_link_for_display(link)
    link.gsub /^https?:\/\//, ''
  end

  def format_link(link)
    if link.present?
      (/^https?:\/\//.match(link) ? link : "http://#{link}")
    end
  end

  def icon_link_class(key, site)
    clz = [:ico, "ico-invert", "ico-#{key}"]
    if key.to_sym == :blog
      site_bits = site.split(".")
      clz << "ico-" + ((site_bits.length > 2) ? site_bits[1] : site_bits[0])
    end
    clz.join(' ')
  end

  def self.keyed_links
    [[:url, 'Website', :u_website]].freeze
  end


end
