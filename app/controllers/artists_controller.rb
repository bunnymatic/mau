require 'xmlrpc/client'
include ArtistsHelper

class ArtistsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :admin_required, :only => [ :unsuspend, :purge]
  before_filter :login_required, :only => [ :edit, :update, :suspend, :deleteart, :destroyart, :addprofile, :deactivate, :setarrangement, :arrangeart ]

  layout 'mau1col'

  # num artists before we paginate
  @@PER_PAGE = 28

  # render new.rhtml
  def new
    @artist = Artist.new
    @studios = Studio.all
  end

  def map
    @view_mode = 'map'
    @roster_link = artists_path + "?v=l"
    @gallery_link = artists_path + "?v=g"

    addresses = []
    artists = Artist.all

    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true)
    @map.icon_global_init( GIcon.new(:image => '/images/icon/map_icon.png',
                                     :iconSize => GSize.new(64.0, 64.0)),'iconname')

    centerx = 0
    centery = 0
    markers = []
    @roster = {}
    nentries = 0
    artists.each do |a|
      address = nil
      name = "%s" % a.get_name
      addr = nil
      s = a.studio
      if s
        addr = "%s %s %s" % [ s.street, s.state, s.zip ]
      else
        if a.street and !a.street.empty?
          addr = "%s %s %s" % [ a.street, a.addr_state, a.zip ]
        end
      end
      if addr
        address = Address.new(name, addr)
        if a.studio_id > 0
          s = a.studio
          if s
            name += " at %s" % s.name
          end
        end
        ky = address.to_s
        dx = dy = 0.0
        if !@roster[ky]
          @roster[ky] = []
        else 
          # add offset
          dx = 0.00015 * rand * ( rand > 0.5 ? -1.0 : 1.0 )
          dy = 0.00025 * rand * ( rand > 0.5 ? -1.0 : 1.0 )
        end

        @roster[ky] << a
        coord = address.coord
        title = address.title
        centerx += coord[0]
        centery += coord[1]
        nentries += 1
        coord[0] += dx
        coord[1] += dy
        info = get_map_info(a)

        m = GMarker.new(coord,:title => title,
                        :info_window => info)
        markers << m
        @map.overlay_init(m)
      end
    end
    center = [ centerx / nentries.to_f,
               centery / nentries.to_f]
    @map.center_zoom_init(center,14)
  end


  def addprofile
    @errors = []
    @artist = self.current_artist
    if !@artist
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
      redirect_back_or_default( artist_path(@artist) )
    end
    @artist.flush_cache
  end

  def upload_profile
    if params[:commit].downcase == 'cancel'
      redirect_to current_artist
      return
    end

    @artist = self.current_artist
    upload = params[:upload]

    if not upload
      flash[:error] = "You must provide a file."
      redirect_to addprofile_artist_path(@artist)
      return
    end

    begin
      post = ArtistProfileImage.save(upload, @artist)
      redirect_to @artist
      return
    rescue
      logger.error("Failed to upload %s" % $!)
      flash[:error] = "%s" % $!
      redirect_to addprofile_artist_path(@artist)
      return
    end
  end


  def edit
    @artist = safe_find_artist(params[:id])
    if @artist
      if self.current_artist != @artist
        flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
        redirect_back_or_default( artist_path(@artist) )
        return
      end
      @studios = Studio.all
    end
  end


  def index
    # rollup artists images so we have all thumbs from artists
    artists = Artist.all { a.sort_by |a| a.get_sort_name }
    nartists = artists.length
    curpage = params[:p] || 0
    curpage = curpage.to_i
    # build alphabetical list keyed by first letter
    @artists_by_name = {}
    pieces = []
    
    vw = "gallery"
    if params[:v] == 'l'
      vw = 'list'
    end
    @view_mode = vw

    nltrs_for_link = 2
    no_image_ct = 0
    artists.each do |a|
      artist_name = a.get_sort_name
      ltr = artist_name[0].chr.upcase
      if !@artists_by_name.has_key?(ltr)
        @artists_by_name[ltr] = []
      end
      @artists_by_name[ltr].push(a)
      piece = a.representative_piece
      if piece == nil
        no_image_ct += 1
      else
        piece['alpha'] = artist_name[0..nltrs_for_link-1].capitalize
        pieces << piece
      end
    end
    logger.debug("Found %d artists without any art" % no_image_ct)
    if vw == 'gallery'
      npieces = pieces.length
      lastpage = (npieces.to_f/@@PER_PAGE.to_f).floor
      curpage = [curpage, lastpage].min
      @pieces, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(pieces, curpage, @@PER_PAGE)
      @pieces.reverse!
      if curpage > lastpage
        curpage = lastpage
      elsif curpage < 0
        curpage = 0
      end
      show_next = (curpage != lastpage)
      show_prev = (curpage > 0)
      arg = "?p=%d" 
      nxtmod = arg % nextpage
      prvmod = arg % prevpage
      lastmod = arg % lastpage
      base_link = "/artists/"
      if show_next
        @next_link = base_link + nxtmod
        @last_link = base_link + lastmod
      end
      if show_prev
        @prev_link = base_link + prvmod
        @first_link = base_link
      end
      # display page and last should be indexed staring with 1 not 0
      @last = lastpage + 1
      @page = curpage + 1

      # compute text links
      @alpha_links = []
      @last.times do |idx|
        firstidx = idx * @@PER_PAGE
        lastidx = [ firstidx + @@PER_PAGE, pieces.length ].min - 1
        firstltr = pieces[firstidx]['alpha']
        lastltr = pieces[lastidx]['alpha']
        lnktxt = "%s - %s" % [firstltr, lastltr]
        lnk = "p=%d" % idx
        @alpha_links << [lnktxt, lnk, curpage == idx ]
      end
    end
    @artists = artists
    @studio = nil
    @page_title = "Mission Artists United - MAU Artists"
    @roster_link = "?v=l"
    @gallery_link = "?v=g"
    if vw == "list"
      render :action => 'roster', :layout => 'mau1col'
    else
      render :action => 'index', :layout => 'mau1col'
    end      
  end


  def destroyart
    # receives post from delete art form
    if ! logged_in?
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
    end
    ids = params[:art].map { |kk,vv| kk if vv != "0" }.compact
    arts = ArtPiece.find(ids)
    arts.each do |art| 
      art.destroy
    end
    redirect_back_or_default(self.current_artist)
  end


  def arrangeart
    @artist = self.current_artist
    if ! @artist
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
      redirect_back_or_default( artist_path(@artist) )
      return
    end
  end

  def setarrangement
    ap = params[:art]
    # double check that represenative is in this artist's collection
    current_artist.representative_art_piece = ap
    if current_artist.save!
      flash[:notice] = "Your represenative image has been updated."
    else
      flash[:error] = "There was a problem setting your represenative image."
    end
    redirect_to current_artist
  end

  def deleteart
    @artist = self.current_artist
    if ! @artist
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
      redirect_back_or_default( artist_path(@artist) )
      return
    end
  end


  def show
    begin
      use_id = Integer(params[:id])
    rescue ArgumentError
      use_id = false
    end
    if !use_id 
      @artist = Artist.find_by_login(params[:id])
      if !@artist or @artist.suspended?
        @artist = nil
        flash.now[:error] = "The artist '" + params[:id] + "' you were looking for was not found."
      end
    else
      @artist = safe_find_artist(params[:id])
      if @artist.suspended?
        flash.now[:error] = "The artist '" + @artist.get_name() + "' is no longer with us."
        @artist = nil
      else
        @page_title = "Mission Artists United - Artist: %s" % @artist.get_name
        # get artist pieces here instead of in the html
        num = @artist.max_pieces - 1
        @art_pieces = @artist.art_pieces.reverse[0..num]
        
        # need to figure out encoding of the message - probably better to post with json
        #twittermsg = "Check out %s at Mission Artists United: %s" % [@artist.get_name(), url]
        # @tw_share = "http://www.twitter.com/home?status=%s" % twittermsg
        url = @artist.get_share_link(true)
        title = CGI::escape( "Check out %s at Mission Artists United" % @artist.get_name() )
        @fb_share = "http://www.facebook.com/sharer.php?u=%s&t=%s" % [ url, title ]
      end
    end
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'mau' }
      format.json  { 
        cleaned = @artist.clean_for_export(@art_pieces)
        render :json => cleaned
      }
    end
  end


  def update
    if params[:commit].downcase == 'cancel'
      redirect_to(self.current_artist)
      return
    end
    begin
      if params[:emailsettings]
        em = params[:emailsettings]
        em.each_pair do |k,v| 
          em[k] = ( v.to_i != 0 ? true : false)
        end
        params[:artist][:email_attrs] = em.to_json
      end
      self.current_artist.update_attributes!(params[:artist])
      flash[:notice] = "Update successful"
      redirect_to(edit_artist_url(current_artist))
    rescue 
      flash[:error] = "%s" % $!
      redirect_to(edit_artist_url(current_artist))
    end
  end


  def create
    logout_keeping_session!
    studio_id = params[:artist][:studio_id] ? params[:artist][:studio_id].to_i() : 0
    if studio_id > 0
      studio = Studio.find(studio_id)
      if studio
        @artist = studio.artists.build(params[:artist])
      end
    else
      @artist = Artist.new(params[:artist])
      if @artist.url && @artist.url.index('http') != 0
        @artist.url = 'http://' + @artist.url
      end
    end
    @artist.register! if @artist && @artist.valid?
    success = @artist && @artist.valid?
    @studios = Studio.all
    if success && @artist.errors.empty?
      # Protects against session fixation attacks, causes request forgery
      # protection if visitor resubmits an earlier form using back
      # button. Uncomment if you understand the tradeoffs.
      flash[:notice] = "Thanks for signing up!  We're sending you an email with your activation code."
      redirect_to "/"
    else
      msg = "There was a problem creating your account.  If you can't solve the issues listed below, please try again later or contact the webmaster (link below). if you continue to have problems."
      flash.now[:error] = msg
      render :action => 'new'
    end
  end
  
  #
  # Change user passowrd
  def change_password_update
    if Artist.authenticate(current_artist.login, params[:old_password])
      if ((params[:password] == params[:password_confirmation]) && !params[:password_confirmation].blank?)
        current_artist.password_confirmation = params[:password_confirmation]
        current_artist.password = params[:password]
        
        if current_artist.save!
          flash[:notice] = "Password successfully updated"
          redirect_to request.env["HTTP_REFERER"] or current_artist
        else
          flash[:error] = "Password not changed"
          redirect_to request.env["HTTP_REFERER"] or current_artist
        end
        
      else
        flash[:error] = "New Password mismatch" 
        redirect_to request.env["HTTP_REFERER"] or current_artist
      end
    else
      flash[:error] = "Old password incorrect" 
      redirect_to request.env["HTTP_REFERER"] or "/"
    end
  end

  def noteform
    # get new note form
    @artist = safe_find_artist(params[:id])
    if !@artist
      @errmsg = "We were unable to find the artist in question."
    end
    render :layout => false
  end

  def notify
    id = Integer(params[:id])
    noteinfo = {}
    ['comment','login','email','page','name'].each do |k|
      if params.include? k
        noteinfo[k] = params[k]
      end
    end
    ArtistMailer.deliver_notify( Artist.find(id), noteinfo)
    render :layout => false
  end

  def activate
    logout_keeping_session!
    artist = Artist.find_by_activation_code(params[:activation_code]) unless params[:activation_code].blank?
    case
    when (!params[:activation_code].blank?) && artist && !artist.active?
      artist.activate!
      flash[:notice] = "Signup complete! Please sign in to continue."
      artist.flush_cache
      Studio.flush_cache
      redirect_to '/login'
    when params[:activation_code].blank?
      flash[:error] = "The activation code was missing.  Please follow the URL from your email."
      redirect_back_or_default('/')
    else 
      flash[:error]  = "We couldn't find a artist with that activation code -- check your email? Or maybe you've already activated -- try signing in."
      redirect_back_or_default('/')
    end
  end

  def resend_activation
    if request.post?
      artist = Artist.find_by_email(params[:artist][:email])
      if artist
        artist.resend_activation
        flash[:notice] = "We sent your activation code to #{artist.email}"
      else
        flash[:notice] = "We can't find any users with email #{params[:artist][:email]} in our system."
      end
      redirect_back_or_default('/')
    end
  end
    
  def forgot
    if request.post?
      artist = Artist.find_by_email(params[:artist][:email])
      if artist
        artist.create_reset_code
        flash[:notice] = "Reset code sent to #{artist.email}"
      else
        flash[:notice] = "No artist with email #{params[:artist][:email]} does not exist in system"
      end
      redirect_back_or_default('/login')
    end
  end
  
  def reset
    @artist = Artist.find_by_reset_code(params[:reset_code]) unless params[:reset_code].nil?
    if request.post?
      if @artist.update_attributes(:password => params[:artist][:password], :password_confirmation => params[:artist][:password_confirmation])
        self.current_artist = @artist
        @artist.delete_reset_code
        flash[:notice] = "Password reset successfully for #{@artist.email}"
        redirect_back_or_default('/')
      else
        render :action => :reset
      end
    end
  end

  def destroy
    @artist.delete!
    flash[:notice] = "Your account has been deactivated."
    Artist.flush_cache
    Studio.flush_cache
    redirect_to artists_path
  end
  def unsuspend
    @artist.unsuspend!
    flash[:notice] = "Your account has been unsuspended"
    Artist.flush_cache    
    redirect_to artists_path
  end
  def suspend
    self.current_artist.suspend!
    flash[:notice] = "Your account has been suspended"
    Artist.flush_cache    
    redirect_to artists_path
  end

  def deactivate
    suspend
    logout_killing_session!
  end

  def purge
    @artist.destroy!
    flash[:notice] = "Your account has been deactivated."
    redirect_to artists_path
  end

  protected
  def safe_find_artist(id)
    begin
      Artist.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The artist you were looking for was not found."
      return nil
    end
  end

  protected
  def get_geocode(address)
    Geocoding::get(address.to_s)
  end  

end
