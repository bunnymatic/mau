# -*- coding: undecided -*-
require 'xmlrpc/client'
include ArtistsHelper
include HTMLHelper

def is_os_only(osonly)
  return (osonly && (["1",1,"on","true"].include? osonly))
end

class ArtistsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :admin_required, :only => [ :unsuspend, :purge, :admin_index, :admin_emails, :admin_update ]
  before_filter :login_required, :only => [ :edit, :update, :suspend, :deleteart, :destroyart, :addprofile, :deactivate, :setarrangement, :arrangeart ]

  layout 'mau1col', :except => 'faq'

  # num artists before we paginate
  @@PER_PAGE = 28

  # render new.rhtml
  def new
    if logged_in?
      flash[:notice] = "You're already logged in"
      redirect_to current_artist
    end
    @artist = Artist.new
    @studios = Studio.all
  end

  def map
    @view_mode = 'map'
    @os_only = is_os_only(params[:osonly])
    roster_args = {'v' => 'l'}
    gallery_args = {'v' => 'g'}
    if @os_only
      gallery_args['osonly'] = 'on'
      roster_args['osonly'] = 'on'
    end
    @roster_link = artists_path + HTMLHelper.queryencode(roster_args)
    @gallery_link = artists_path + HTMLHelper.queryencode(gallery_args)
    addresses = []
    if @os_only
      artists = Artist.find(:all, :conditions => [ 'osoct2010 = 1' ])
    else
      artists = Artist.all
    end
    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true)
    # init icon
    @map.icon_global_init( GIcon.new(:image => '/images/icon/map_icon.png', 
                                     :iconSize => GSize.new(64.0, 64.0)),
                           'icon_name')
    centerx = 0
    centery = 0
    markers = []
    @roster = {}
    nentries = 0
    artists.each do |a|
      if a.address && !a.address.empty? and a.lat and a.lng
        ky = "%s" % a.address
        dx = dy = 0.0
        if !@roster[ky]
          @roster[ky] = []
        else 
          # add offset
          dx = 0.00015 * rand * ( rand > 0.5 ? -1.0 : 1.0 )
          dy = 0.00025 * rand * ( rand > 0.5 ? -1.0 : 1.0 )
        end

        @roster[ky] << a
        coord = [a.lat, a.lng]
        centerx += coord[0]
        centery += coord[1]
        nentries += 1
        coord[0] += dx
        coord[1] += dy
        info = get_map_info(a)
        
        m = GMarker.new(coord,:title => a.get_name(true),
                        :info_window => info)
        #:icon => artist_ico)
        markers << m
        @map.overlay_init(m)
      end
    end
    center = [ centerx / nentries.to_f,
               centery / nentries.to_f]
    @map.center_zoom_init(center,14)
    @selfurl = artistsmap_url
    @inparams = params
    @inparams.delete('action')
    @inparams.delete('controller')
  end

  def admin_index
    sortby = "studio_id"
    reverse = false
    @allowed_sortby = ['studio_id','lastname','firstname','id','login','osoct2010','email']
    if params[:sortby]
      if @allowed_sortby.include? sortby
        sortby = params[:sortby]
        reverse = false
      end
    end
    if params[:rsortby]
      rsortby = params[:rsortby] || "studio_id"
      if @allowed_sortby.include? rsortby
        sortby = rsortby
        reverse = true
      end
    end
    @artists = Artist.find(:all, :order => sortby)
    if reverse
      @artists = @artists.reverse()
    end
  end
  
  def admin_update
    begin
      ct = 0
      params.each do |k,v|
        m = /^ARTIST(\d+)$/.match(k)
        if m and m.length == 2
          artistid = m[1]
          a = Artist.find(artistid)
          if a
            a.os2010 = (v.to_s == 'true')
            a.save
            ct = ct + 1
          end
        end
      end
      flash[:notice] = "Updated %d artists" % ct
      redirect_to(admin_artists_url())
    rescue 
      flash[:error] = "%s" % $!
      redirect_to(admin_artists_url())
    end
  end

  def addprofile
    @errors = []
    @artist = self.current_artist
    if !@artist
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
      redirect_back_or_default( artist_path(@artist) )
    end
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
    if !@artist
      redirect_to "/"
      return
    else
      if self.current_artist != @artist
        flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
        redirect_back_or_default( artist_path(@artist) )
        return
      end
      @studios = Studio.all
    end
  end


  def index
    # collect query args to build links
    queryargs = {}
    @os_only = is_os_only(params[:osonly])
    if @os_only
      artists = Artist.find(:all, :conditions => [ 'osoct2010 = 1' ]).sort_by { |a| a.get_sort_name }
      queryargs['osonly'] = "on"
    else
      artists = Artist.all.sort_by { |a| a.get_sort_name }
    end

    nartists = artists.length
    curpage = params[:p] || 0
    curpage = curpage.to_i
    # build alphabetical list keyed by first letter
    @artists_by_name = {}
    pieces = []
    
    vw = "gallery"
    queryargs["v"] = params[:v]
    
    if params[:v] == 'l'
      vw = 'list'
    end
    if @os_only
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

      base_link = "/artists/"

      if show_next
        queryargs["p"] = nextpage
        @next_link = base_link + HTMLHelper.queryencode(queryargs)
        queryargs["p"] = lastpage
        @last_link = base_link + HTMLHelper.queryencode(queryargs)
      end
      if show_prev
        queryargs["p"] = prevpage
        @prev_link = base_link + HTMLHelper.queryencode(queryargs)
        queryargs.delete('p')
        @first_link = base_link + HTMLHelper.queryencode(queryargs)
      end
      # display page and last should be indexed staring with 1 not 0
      @last = lastpage + 1
      @page = curpage + 1

      # compute text links
      @alpha_links = []
      if pieces.length > 0
        @last.times do |idx|
          firstidx = idx * @@PER_PAGE
          lastidx = [ firstidx + @@PER_PAGE, pieces.length ].min - 1
          firstltr = pieces[firstidx]['alpha']
          lastltr = pieces[lastidx]['alpha']
          lnktxt = "%s - %s" % [firstltr, lastltr]
          queryargs["p"] = idx
          @alpha_links << [lnktxt, HTMLHelper.queryencode(queryargs), curpage == idx ]
        end
      end
    end
    @artists = artists
    @studio = nil
    @page_title = "Mission Artists United - MAU Artists"
    roster_args = {'v' => 'l'}
    gallery_args = {'v' => 'g'}
    if @os_only
      gallery_args['osonly'] = 'on'
      roster_args['osonly'] = 'on'
    end
    @roster_link = HTMLHelper.queryencode(roster_args)
    @gallery_link = HTMLHelper.queryencode(gallery_args)
    roster_args.delete('v')
    @map_link = artistsmap_path + HTMLHelper.queryencode(roster_args)

    @inparams = params
    @inparams.delete('action')
    @inparams.delete('controller')
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
      if @artist && @artist.suspended?
        flash.now[:error] = "The artist '" + @artist.get_name(true) + "' is no longer with us."
        @artist = nil
      end
    end
    if @artist != nil
      @page_title = "Mission Artists United - Artist: %s" % @artist.get_name(true)
      # get artist pieces here instead of in the html
      num = @artist.max_pieces - 1
      @art_pieces = @artist.art_pieces.reverse[0..num]
      
      # need to figure out encoding of the message - probably better to post with json
      #twittermsg = "Check out %s at Mission Artists United: %s" % [@artist.get_name(), url]
      # @tw_share = "http://www.twitter.com/home?status=%s" % twittermsg
      url = @artist.get_share_link(true)
      raw_title = "Check out %s at Mission Artists United" % @artist.get_name() 
      title = CGI::escape( raw_title )
      @fb_share = "http://www.facebook.com/sharer.php?u=%s&t=%s" % [ url, title ]
      status = "%s #missionartistsunited " % raw_title
      @tw_share = "http://twitter.com/home?status=%s%s" % [CGI::escape(status), url]
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
        em2 = {}
        em.each_pair do |k,v| 
          em2[k] = ( v.to_i != 0 ? true : false)
        end
        params[:artist][:email_attrs] = em2.to_json
      end
      # clean os from radio buttons
      os = params[:artist][:osoct2010]
      if os == "true" || os == "on" || os == 1
        if ((!params[:artist][:street]) || (params[:artist][:street].empty?)) && (current_artist.studio && current_artist.studio.id <= 0)
          raise "You don't appear to have a street address set.  If you are going to do Open Studios, please make sure you have a valid street address in 94110 zipcode (or studio affiliation) before setting your Open Studios status to YES."
        end
        params[:artist][:osoct2010] = true
      elsif os == "false" || os == "off"
        params[:artist][:osoct2010] = false
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
        if artist.state == 'active'
          artist.create_reset_code
          flash[:notice] = "Reset code sent to #{artist.email}"
        else
          flash[:error] = "That artist is not yet active.  Have you responded to the activation email we already sent?  Enter your email below if you need us to send you a new activation email."
          redirect_back_or_default('/resend_activation')
          return
        end
      else
        flash[:notice] = "No artist with email #{params[:artist][:email]} does not exist in system"
      end
      redirect_back_or_default('/login')
    end
  end

  def faq
    render :action => 'faq', :layout => 'mau2col'
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
    redirect_to artists_path
  end
  def unsuspend
    @artist.unsuspend!
    flash[:notice] = "Your account has been unsuspended"
    redirect_to artists_path
  end
  def suspend
    self.current_artist.suspend!
    flash[:notice] = "Your account has been suspended"
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

  def badge
    artist = safe_find_artist(params[:id])
    url = "/"
    if artist
      url = artist_path(artist)
    end
    @lnk = "http://%s%s" % [Conf.site_url, url]
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

end
