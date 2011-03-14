# -*- coding: undecided -*-
require 'xmlrpc/client'
include ArtistsHelper
include HTMLHelper

def is_os_only(osonly)
  return (osonly && (["1",1,"on","true"].include? osonly))
end

class ArtistsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead

  before_filter :admin_required, :only => [ :purge, :admin_index, :admin_emails, :admin_update ]
  before_filter :login_required, :only => [ :edit, :update, :deleteart, :destroyart, :setarrangement, :arrangeart ]

  after_filter :store_location, :except => [:show]  # may handle these separately in case of error pages

  layout 'mau1col', :except => 'faq'

  # num artists before we paginate
  @@PER_PAGE = 28

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
      artists = Artist.active.open_studios_participants
    else
      artists = Artist.active
    end
    artists.reject!{ |a| !a.in_the_mission? }

    @map = GMap.new("map")
    @map.control_init(:large_map => true, :map_type => true)
    # init icon
    @map.icon_global_init( GIcon.new(:image => '/images/icon/map_icon.png', 
                                     :iconSize => GSize.new(64.0, 64.0)),
                           'icon_name')
    markers = []
    @roster = {}
    nentries = 0

    artists.each do |a|
      address = a.address_hash
      if !address.nil? && address[:geocoded] && !address[:simple].blank?
        ky = "%s" % address[:simple]
        dx = dy = 0.0
        if !@roster[ky]
          @roster[ky] = []
        else 
          # add offset
          dx = 0.00015 * rand * ( rand > 0.5 ? -1.0 : 1.0 )
          dy = 0.00025 * rand * ( rand > 0.5 ? -1.0 : 1.0 )
        end
        
        @roster[ky] << a
        coord = address[:latlng]
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
    sw = Artist::BOUNDS['SW']
    ne = Artist::BOUNDS['NE']
    @map.center_zoom_on_bounds_init([sw,ne])
    @selfurl = artistsmap_url
    @inparams = params
    @inparams.delete('action')
    @inparams.delete('controller')
  end

  def admin_index
    sortby = "studio_id"
    reverse = false
    @allowed_sortby = ['studio_id','lastname','firstname','id','login','email']
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
    @artists = Artist.active.all(:order => sortby)
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
            a.artist_info.os_participation = {'201104' => v}
            a.artist_info.save
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


  def edit
    if current_user[:type] != 'Artist'
      redirect_to edit_user_path(current_user)
      return
    end
    @studios = Studio.all
    @artist_info = current_user.artist_info || ArtistInfo.new({ :id => current_user.id })
  end

  def by_firstname 
    @page_title = "Artists by first name"    
    return sorted_by 'firstname'
  end
  def by_lastname
    @page_title = "Artists by last name"
    return sorted_by 'lastname'
  end
  
  def index
    respond_to do |format| 
      format.mobile { 
        @artists = []
        @page_title = "Artists"
        render :layout => 'mobile' 
      }
      format.html {
        # collect query args to build links
        queryargs = {}
        @os_only = is_os_only(params[:osonly])
        if @os_only
          artists = Artist.active.open_studios_participants.sort_by { |a| a.get_sort_name }
          queryargs['osonly'] = "on"
          artists.reject!{ |a| !a.in_the_mission? }
        else
          artists = Artist.active.sort_by { |a| a.get_sort_name }
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
      }
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
    redirect_to(artist_path(current_user))
  end


  def arrangeart
    @artist = current_user
    if ! @artist
      flash.now[:error]  = "You can't edit an account that's not your own.  Try logging in first."
      redirect_back_or_default( artist_path(@artist) )
      return
    end
  end

  def setarrangement
    if params.has_key? :art
      ap = params[:art]
      # double check that represenative is in this artist's collection
      if ap.artist_id != current_user.id
        flash[:error] = "There was a problem setting your representative image."
        redirect_to user_path(current_artist)
        return
      end
      current_user.representative_art_piece = ap
      if current_user.save!
        flash[:notice] = "Your representative image has been updated."
      else
        flash[:error] = "There was a problem setting your representative image."
      end
    elsif params.has_key? :neworder
      # new endpoint for rearranging - more than just setting representative
      neworder = params[:neworder].split(',')
      new_rep = neworder[0]
      ctr = 0
      current_artist.representative_art_piece = new_rep
      current_artist.save
      begin
        neworder.each do |apid|
          a = ArtPiece.find(apid)
          a.order = ctr
          a.save
          ctr+=1
        end
        flash[:notice] = "Your images have been reordered."
      rescue
        flash[:error] = "There was a problem reordering your images. You may try again but if the problem persists, please write to help@missionartistsunited.org."
      end
    else
      flash[:error] ="There was a problem interpreting the input parameters.  Please try again."
    end
    redirect_to user_path(current_user)
  end

  def deleteart
    @artist = self.current_user
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
      @art_pieces = @artist.art_pieces[0..num]
      store_location
    end
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'mau' }
      format.json  { 
        cleaned = @artist.clean_for_export(@art_pieces)
        render :json => cleaned
      }
      format.mobile {
        @page_title = (@artist ? @artist.get_name(true) : '')
        render :layout => 'mobile'
      }
    end
  end

  def update
    if commit_is_cancel
      redirect_to user_path(current_user)
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
      artist_info = params[:artist][:artist_info]
      params[:artist].delete(:artist_info)
      
      os = artist_info[:os_participation]
      if !os.nil? 
        # trueify params 
        os = Hash[os.map{|k,v| [k, (v==true || v=='true' || v=='on' || v=='1' || v==1)]}]
        if os.value?(true) 
          if current_artist.address.blank?
            raise "You don't appear to have a street address set.  If you are going to do Open Studios, please make sure you have a valid street address in 94110 zipcode (or studio affiliation) before setting your Open Studios status to YES."
          end
        end
        current_artist.artist_info.os_participation = os
        artist_info.delete(:os_participation)
      end
      current_artist.artist_info.update_attributes!(artist_info)
      current_artist.update_attributes!(params[:artist])
      flash[:notice] = "Update successful"
      redirect_to edit_artist_url(current_user)
    rescue 
      flash[:error] = "%s" % $!
      redirect_to edit_artist_url(current_user)
    end
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
  def sorted_by sort_column
    @artists = Artist.active.find(:all, :order => sort_column)
    respond_to do |format| 
      format.mobile { 
        render :layout => 'mobile', :template => 'artists/index.mobile'
      }
    end
  end

end
