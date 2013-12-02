class ArtistPresenter

  attr_accessor :artist
  delegate :city, :street, :id, :bio, :doing_open_studios?, :media, :get_name, :studio, :login, :to => :artist

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
      if @artist.is_a? Artist
        num = @artist.max_pieces - 1
        @art_pieces = @artist.art_pieces[0..num]
      else
        @art_pieces = []
      end
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
    valid_address?(@artist.address_hash)
  end

  def map_url
    if @artist.studio
      @artist.studio.map_link
    else
      @artist.map_link
    end
  end

  private
  def valid_address?(address_hash)
    address_hash[:parsed].slice(:street, :city).values.any?(&:present?)
  end


end
