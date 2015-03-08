# This presenter adds helpful display/view related methods
# to make it easy to draw artist data on a page

class ArtistPresenter < UserPresenter

  attr_accessor :model
  
  delegate :doing_open_studios?, :media, :os_participation, :studio, :studio_id,
           :artist_info,
           to: :artist, allow_nil: true

  def artist
    model
  end

  # def favorites_of_my_work
  #   @favorites_of_my_work ||=
  #     begin
  #       if self.respond_to? :art_pieces
  #         art_piece_ids = art_pieces.map(&:id)
  #         Favorite.art_pieces.where(favoritable_id: art_piece_ids).order('created_at desc')
  #       else
  #         []
  #       end
  #     end
  # end

  def has_media?
    model.media.present?
  end

  def has_bio?
    model.try(:bio) and !model.bio.empty?
  end

  def allows_email_from_artists?
    model.emailsettings['fromartist']
  end

  # def links
  #   @links ||= KEYED_LINKS.map do |kk, disp, _id|
  #     lnk = format_link(model.send(kk))
  #     [_id, disp, lnk] if lnk.present?
  #   end.compact
  # end

  # def links_html
  #   KEYED_LINKS.map do |key, display, _id|
  #     site = model.send(key)
  #     if site.present?
  #       formatted_site = format_link(site)
  #       site_display = format_link_for_display(site)
  #       link_icon_class = icon_link_class(key, site)
  #       content_tag 'a', href: formatted_site, title: display, target: '_blank' do
  #         content_tag(:i,'', class: link_icon_class) + 
  #           content_tag(:span,site_display)
  #       end
  #     end
  #   end.compact
  # end

  # def fb_share_link
  #   "http://www.facebook.com/sharer.php?u=%s&t=%s" % [ share_url, CGI::escape( share_title ) ]
  # end

  # def tw_share_link
  #   status = "%s @sfmau #missionartistsunited " % share_title
  #   @tw_share = "http://twitter.com/home?status=%s%s" % [CGI::escape(status), share_url]
  # end

  def has_art?
    artist && art_pieces.present?
  end

  def art_pieces
    @art_pieces ||=
      begin
        num = artist.max_pieces - 1
        pieces = artist.art_pieces[0..num].compact.map{|piece| ArtPiecePresenter.new(piece)}
      end
  end

  def favorites_count
    @favorites_count ||= who_favorites_me.count
    @favorites_count if @favorites_count > 0
  end

  def studio_name
    @studio_name ||= studio.name
  end

  def studio_number
    number = artist.artist_info.try(:studionumber)
    number.present? ? ('#' + number) : ''
  end

  def has_address?
    model.has_address?
  end

  def in_the_mission?
    model.in_the_mission?
  end

  def map_url
    if model.studio
      model.studio.map_link
    else
      model.map_link
    end
  end

  # def favorites_path(opts = nil)
  #   url_helpers.user_favorites_path(artist)
  # end
  
  def get_map_info
    content_tag('div', map_info_contents, class: 'map__info-window')
  end

  def representative_piece
    @representative_piece ||=
      begin
        r = artist.representative_piece
        ArtPiecePresenter.new(r) if r.is_a?(ArtPiece)
      end
  end

  def map_info_contents
    thumb = content_tag('div', linked_thumb, class: 'map__info-window-art')
    [thumb, map_info_name_address].compact.join.html_safe
  end

  def map_info_name_address
    content_tag 'div', class: 'map__info-window-text' do
      name = content_tag 'a', get_name, href: url_helpers.artist_path(model)
      html = [name]
      street = address_hash.try(:parsed).try(:street)
      if artist.studio
        html << content_tag('div', artist.try(:studio).try(:name), class: 'studio')
        html << content_tag('div', street)
      else
        html << content_tag('div', street)
      end
      html.map(&:html_safe).join.html_safe
    end
  end

  def bio_html
    @bio_html ||= begin
                    if bio.present?
                      MarkdownService.markdown(bio, :filter_html)
                    else
                      content_tag('h4', "No artist's statement")
                    end
                  end
  end

  def profile_image(size = small)
    if has_profile_image
      artist.get_profile_image(size)
    else
      "/images/default-artist.png"
    end
  end

  private

  def share_url
    @share_url ||= artist.get_share_link(true)
  end

  def share_title
    @share_title ||= "Check out %s at Mission Artists United" % get_name
  end

  def map_thumb
    @representative_thumb ||= representative_piece.get_path('thumb')
  end

  def map_thumb_image
    @representative_thumb_image ||= content_tag('div', '', class: 'thumb', style: "background-image: url(#{map_thumb});")
  end

  def linked_thumb
    if representative_piece
      @linked_thumb ||= content_tag('a', map_thumb_image, href: url_helpers.artist_path(model))
    end
  end

  def self.keyed_links
    [ [:url, 'Website', :u_website],
      [:instagram, 'Instagram', :u_instagram],
      [:facebook, 'Facebook', :u_facebook],
      [:twitter, 'Twitter', :u_twitter],
      [:pinterest, 'Pinterest', :u_pinterest],
      [:flickr, 'Flickr', :u_flickr],
      [:blog, 'Blog', :u_blog],
      [:myspace, 'MySpace', :u_myspace]].freeze
  end

end
