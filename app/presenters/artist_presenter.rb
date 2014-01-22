class ArtistPresenter

  include HtmlHelper

  attr_accessor :artist
  delegate :name, :state, :firstname, :lastname, :representative_piece, :city, :street, :id, :bio, :doing_open_studios?, :media, :address, :address_hash, :get_name, :studio, :studio_id, :login, :active?, :to => :artist

  def initialize(view_context, artist)
    @artist = artist
    @view_context = view_context
  end

  def has_media?
    @artist.media.present?
  end

  def has_bio?
    @artist.bio and !@artist.bio.empty?
  end

  def allows_email_from_artists?
    @artist.emailsettings['fromartist']
  end

  def has_links?
    @has_links ||= (Artist::KEYED_LINKS.detect do |kk, disp|
                      artist.send(kk).present?
                    end).present?
  end

  def links
    Artist::KEYED_LINKS.map do |kk, disp, _id|
      lnk = @artist.send(kk)
      [_id, disp, lnk] if lnk.present?
    end.compact
  end

  def fb_share_link
    url = @artist.get_share_link(true)
    raw_title = "Check out %s at Mission Artists United" % @artist.get_name()
    title = CGI::escape( raw_title )
    "http://www.facebook.com/sharer.php?u=%s&t=%s" % [ url, title ]
  end

  def tw_share_link
    url = @artist.get_share_link(true)
    raw_title = "Check out %s at Mission Artists United" % @artist.get_name()
    status = "%s @sfmau #missionartistsunited " % raw_title
    @tw_share = "http://twitter.com/home?status=%s%s" % [CGI::escape(status), url]
  end

  def has_art?
    art_pieces.length > 0
  end

  def art_pieces
    unless @art_pieces
      num = @artist.max_pieces - 1
      @art_pieces = @artist.art_pieces[0..num]
    end
    @art_pieces
  end

  def favorites_count
    @favorites_count ||= @artist.who_favorites_me.count
    @favorites_count if @favorites_count > 0
  end

  def is_current_user?
    @view_context.current_user == @artist
  end

  def studio_name
    @studio_name ||= studio.name
  end

  def studio_number
    number = @artist.artist_info.studionumber
    number.present? ? ('#' + @artist.artist_info.studionumber) : ''
  end

  def has_address?
    valid_address?
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

  # get info for google map info window as html
  # if you have lat lon, include it for directions link
  def marker_style
    '<style type="text/css">._mau1 { color: #222222; font-size: x-small; } ._mau1 a{ color: #ff2222; }</style>'
  end

  def get_map_info
    [].tap do |bits|
      bits << marker_style
      bits << @view_context.content_tag('div', map_info_contents, :class => '_mau1').html_safe
    end.join.html_safe
  end

  def map_info_contents
    ap = artist.representative_piece
    img = ''
    # tried to add title to these links, but it seems google maps
    # is too smart for that.
    html = ''
    if (ap && ap.is_a?(ArtPiece))
      img = "<a class='lkdark' href='%s'><img src='%s'/></a>" % [ show_path, ap.get_path('thumb') ]
      html += '<div style="float:right;">%s</div>' % img
    end
    html += map_info_name_address
    html += @view_context.content_tag("div", '', :style => 'clear:both;')
    html.html_safe
  end

  def map_info_name_address
    html = ''
    name = "<a class='lkdark' href='%s'>%s</a>" % [ show_path, artist.get_name(true) ]
    street = address_hash[:parsed][:street]
    if artist.studio && artist.studio_id != 0
      html += "%s<div>%s</div>" % [ name, street ]
    else
      html += "%s<div>%s</div><div>%s</div>" % [name, artist.try(:studio).try(:name), street]
    end
    html.html_safe
  end

  def bio_html
    bio.split("\n").map do |line|
      (html_encode(line) + "<br/>")
    end.join.html_safe
  end

  private
  def valid_address?
    address_hash[:parsed].slice(:street, :city).values.any?(&:present?)
  end

  def clean_link(link)
    (link =~ /^https?:\/\//) ? link : ('http://' + link)
  end

end
