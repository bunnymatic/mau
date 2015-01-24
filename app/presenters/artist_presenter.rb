# This presenter adds helpful display/view related methods
# to make it easy to draw artist data on a page

class ArtistPresenter

  include HtmlHelper

  KEYED_LINKS = [ [:url, 'Website', :u_website],
                  [:instagram, 'Instagram', :u_instagram],
                  [:facebook, 'Facebook', :u_facebook],
                  [:twitter, 'Twitter', :u_twitter],
                  [:pinterest, 'Pinterest', :u_pinterest],
                  [:flickr, 'Flickr', :u_flickr],
                  [:blog, 'Blog', :u_blog],
                  [:myspace, 'MySpace', :u_myspace]]

  attr_accessor :artist
  delegate :name, :state, :firstname, :lastname, :nomdeplume, :city, :street, :id,
    :bio, :doing_open_studios?, :media, :address, :address_hash, :get_name,
    :os_participation, :studio, :studio_id, :login, :active?, :artist_info,
    :activated_at, :email, :last_login, :full_name,
    :to => :artist, :allow_nil => true

  def initialize(view_context, artist)
    @artist = artist
    @view_context = view_context
  end
  
  def what_i_favorite
    # collect artist and art piece stuff
    @what_i_favorite ||=
      begin
        user_favorites, art_piece_favorites = artist.favorites.partition do |fav|
          ['Artist', 'User', 'MAUFan'].include? fav.favoritable_type
        end
        
        [User.find(user_favorites.map(&:favoritable_id)),
         ArtPiece.find(art_piece_favorites.map(&:favoritable_id))].flatten.compact.uniq
      end
  end

  def who_favorites_me
    @who_favorites_me ||=
      begin
        favs = (favorites_of_me + favorites_of_my_work).flatten
        User.find(favs.select{|f| f.try(:user_id)}.compact.uniq.map(&:user_id))
      end
  end

  def favorites_of_me
    @favorites_of_me ||= Favorite.users.where(favoritable_id: self.id).order('created_at desc')
  end

  def favorites_of_my_work
    @favorites_of_my_work ||=
      begin
        if self.respond_to? :art_pieces
          art_piece_ids = art_pieces.map(&:id)
          Favorite.art_pieces.where(favoritable_id: art_piece_ids).order('created_at desc')
        else
          []
        end
      end
  end

  def sidebar_art
    art_pieces[0..3]
  end

  def valid?
    !artist.nil?
  end

  def created_at
    artist.created_at.strftime("%m/%d/%y")
  end

  def activation_state
    artist.activated_at ? artist.activated_at.strftime("%m/%d/%y") : artist.state
  end

  def has_activation_code?
    artist.state != 'active' && artist.activation_code.present?
  end

  def has_reset_code?
    artist.reset_code.present?
  end

  def activation_link
    @view_context.activate_url(artist.activation_code)
  end

  def reset_password_link
    @view_context.reset_url(artist.reset_code )
  end

  def has_media?
    @artist.media.present?
  end

  def has_bio?
    @artist.try(:bio) and !@artist.bio.empty?
  end

  def allows_email_from_artists?
    @artist.emailsettings['fromartist']
  end

  def has_links?
    @has_links ||= links.present?
  end

  def links
    @links ||= KEYED_LINKS.map do |kk, disp, _id|
      lnk = format_link(@artist.send(kk))
      [_id, disp, lnk] if lnk.present?
    end.compact
  end

  def links_html
    KEYED_LINKS.map do |key, display, _id|
      site = @artist.send(key)
      if site.present?
        formatted_site = format_link(site)
        site_display = format_link_for_display(site)
        link_icon_class = icon_link_class(key, site)
        @view_context.content_tag 'a', href: formatted_site, title: display, target: '_blank' do
          @view_context.content_tag(:i,'', class: link_icon_class) + 
            @view_context.content_tag(:span,site_display)
        end
      end
    end.compact
  end

  def fb_share_link
    "http://www.facebook.com/sharer.php?u=%s&t=%s" % [ share_url, CGI::escape( share_title ) ]
  end

  def tw_share_link
    status = "%s @sfmau #missionartistsunited " % share_title
    @tw_share = "http://twitter.com/home?status=%s%s" % [CGI::escape(status), share_url]
  end

  def has_art?
    artist && art_pieces.present?
  end

  def art_pieces
    @art_pieces ||=
      begin
        num = artist.max_pieces - 1
        pieces = artist.art_pieces[0..num].compact.map{|piece| ArtPiecePresenter.new(@view_context,piece)}
      end
  end

  def favorites_count
    @favorites_count ||= who_favorites_me.count
    @favorites_count if @favorites_count > 0
  end

  def is_current_user?
    @view_context.current_user == @artist
  end

  def studio_name
    @studio_name ||= studio.name
  end

  def studio_number
    number = artist.artist_info.try(:studionumber)
    number.present? ? ('#' + number) : ''
  end

  def has_address?
    @artist.has_address?
  end

  def in_the_mission?
    @artist.in_the_mission?
  end

  def map_url
    if @artist.studio
      @artist.studio.map_link
    else
      @artist.map_link
    end
  end

  def show_path
    @view_context.artist_path(artist)
  end

  def edit_path(opts = nil)
    opts ||= {}
    @view_context.edit_artist_path(artist, opts)
  end

  # get info for google map info window as html
  # if you have lat lon, include it for directions link
  def marker_style
    '<style type="text/css">._mau1 { color: #222222; font-size: x-small; } ._mau1 a{ color: #ff2222; }</style>'
  end

  def get_map_info
    [].tap do |bits|
      bits << marker_style
      bits << content_tag('div', map_info_contents, :class => '_mau1')
    end.map(&:html_safe).join.html_safe
  end

  def representative_piece
    @representative_piece ||=
      begin
        r = artist.representative_piece
        ArtPiecePresenter.new(@view_context,r) if r.is_a?(ArtPiece)
      end
  end

  def map_info_contents
    [].tap do |html|
      html << (content_tag 'div', linked_thumb, :style => "float:right;") if representative_piece
      html << map_info_name_address
      html << content_tag("div", '', :style => 'clear:both;')
    end.map(&:html_safe).join.html_safe
  end

  def map_info_name_address
    name = content_tag 'a', get_name, :href => show_path, :class => :lkdark
    html = [name]
    street = address_hash.try(:parsed).try(:street)
    if artist.studio && artist.studio_id != 0
      html << content_tag('div', artist.try(:studio).try(:name), :class => 'studio')
      html << content_tag('div', street)
    else
      html << content_tag('div', street)
    end
    html.map(&:html_safe).join.html_safe
  end

  def for_mobile_list
    get_name(true)
  end

  def os_star
    @os_star ||= artist.doing_open_studios?
  end

  def bio_html
    @bio_html ||= begin
                    if bio.present?
                      MarkdownService.markdown(bio, :filter_html)
                    else
                      @view_context.content_tag('h4', "No artist's statement")
                    end
                  end
  end

  def profile_image(size = small)
    if artist.profile_image?
      artist.get_profile_image(size)
    else
      "/images/default-artist.png"
    end
  end

  private
  def content_tag(*args)
    @view_context.content_tag(*args)
  end

  def share_url
    @share_url ||= artist.get_share_link(true)
  end

  def share_title
    @share_title ||= "Check out %s at Mission Artists United" % get_name
  end

  def representative_thumb
    @representative_thumb ||= representative_piece.get_path('thumb')
  end

  def representative_thumb_image
    @representative_thumb_image ||= @view_context.tag('img', :src => representative_thumb)
  end

  def linked_thumb
    @linked_thumb ||= content_tag('a', representative_thumb_image, :class => 'lkdark', :href => show_path)
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

  def format_link_for_display(link)
    link.gsub /^https?:\/\//, ''
  end

end
