# -*- coding: utf-8 -*-
require 'xmlrpc/client'
include ArtistsHelper
include HTMLHelper

Mime::Type.register "image/png", :png

class ArtistsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['artist_names']['cache_key']
  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['artist_names']['cache_exipry']

  before_filter :admin_required, :only => [ :purge, :admin_index, :admin_update ]
  before_filter :login_required, :only => [ :edit, :update, :deleteart, :destroyart, :setarrangement, :arrangeart ]
  before_filter :editor_required, :only => [ :notify_featured ]

  after_filter :store_location, :except => [:show]  # may handle these separately in case of error pages

  layout 'mau1col', :except => 'faq'

  # num artists before we paginate

  def notify_featured
    id = Integer(params[:id])
    ArtistMailer.notify_featured(Artist.find(id)).deliver!
    render :layout => false, :nothing => true, :status => :ok
  end

  def map_page
    @view_mode = 'map'
    @os_only = is_os_only(params["osonly"])
    roster_args = {'v' => 'l'}
    gallery_args = {'v' => 'g'}
    if @os_only
      gallery_args['osonly'] = 'on'
      roster_args['osonly'] = 'on'
    end
    @roster_link = artists_path + HTMLHelper.queryencode(roster_args)
    @gallery_link = artists_path + HTMLHelper.queryencode(gallery_args)
    addresses = []

    active_artists = Artist.active
    if @os_only
      artists = active_artists.open_studios_participants.all(:include => :artist_info)
    else
      artists = active_artists.active.all(:include => :artist_info)
    end

    artists.reject!{ |a| !a.in_the_mission? }

    markers = []
    @roster = {}
    nentries = 0

    artists.each do |a|
      address = a.address_hash
      if !address.nil? && address[:geocoded] && !address[:simple].blank?
        ky = "%s" % address[:simple] 
        if !@roster[ky]
          @roster[ky] = []
        end

        @roster[ky] << a
      end
    end

    @map_data = Gmaps4rails.build_markers(@roster.values.flatten) do |artist, marker|
      address = artist.address_hash
      marker.lat address[:latlng][0]
      marker.lng address[:latlng][1]
      marker.infowindow get_map_info(artist)
    end

    @selfurl = map_artists_url
    @inparams = params
    @inparams.delete('action')
    @inparams.delete('controller')

    render :map
  end

  def admin_index
    sortby = "studio_id"
    reverse = false
    @allowed_sortby = ['studio_id','lastname','firstname','id','login','email', 'activated_at']
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
    @artists = Artist.all(:order => sortby, :include => :artist_info)
    if reverse
      @artists = @artists.reverse()
    end
    respond_to do |format|
      format.html { render :layout => 'mau-admin' }
      format.csv {
        render_csv :filename => 'mau_artists' do |csv|
          csv << ["First Name","Last Name","Full Name","Group Site Name","Studio Address","Studio Number","Email Address"]
          @artists.each do |artist|
            csv << [ artist.csv_safe(:firstname), artist.csv_safe(:lastname), artist.get_name, artist.studio ? artist.studio.name : '', artist.address_hash[:parsed][:street], artist.studionumber, artist.email ]
          end
        end
      }
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
            a.artist_info.os_participation = { Conf.oslive.to_s => v}
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
    @openstudios_question = CmsDocument.packaged(:artists_edit, :openstudios_question)
  end

  def by_firstname
    if !is_mobile?
      redirect_to root_path and return
    end

    @page_title = "Artists by first name"
    @artists = Artist.active.includes(:artist_info).order('firstname').all
    render 'artists/index.mobile', :layout => 'mobile'
  end

  def by_lastname
    if !is_mobile?
      redirect_to root_path and return
    end

    @page_title = "Artists by last name"
    @artists = Artist.active.includes(:artist_info).order('lastname').all
    render 'artists/index.mobile', :layout => 'mobile'
  end

  def index
    respond_to do |format|
      format.html {
        # collect query args to build links
        queryargs = {}
        t = Time.zone.now
        @os_only = is_os_only(params[:osonly])
        if @os_only
          artists = Artist.active.open_studios_participants.all(:include => :artist_info).sort_by(&:sortable_name)
          queryargs['osonly'] = "on"
          artists.reject!{ |a| !a.in_the_mission? }
        else
          artists = Artist.active.all(:include => :artist_info).sort_by { |a| a.get_sort_name }
        end
        dt = Time.zone.now - t
        logger.debug("Get Artists [%s ms]" % dt)
        curpage = params[:p] || 0
        curpage = curpage.to_i
        # build alphabetical list keyed by first letter
        @artists_by_name = {}

        vw = "gallery"
        queryargs["v"] = params[:v]
        if params[:v] == 'l'
          vw = 'list'
        end
        if @os_only
        end
        @view_mode = vw

        if vw == 'gallery'
          @gallery_presenter = ArtistGalleryPresenter.new(view_context, artists, curpage)
        end
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
        @map_link = map_artists_path + HTMLHelper.queryencode(roster_args)

        @inparams = params
        @inparams.delete('action')
        @inparams.delete('controller')
        if vw == "list"
          @artists = artists
          render :action => 'roster', :layout => 'mau1col'
        else
          render :action => 'index', :layout => 'mau1col'
        end
      }
      format.json {
        render :json => Artist.active
      }
      format.mobile {
        @artists = []
        @page_title = "Artists"
        render :layout => 'mobile'
      }
    end
  end

  def suggest
    # grab all names from the cache
    cacheout = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    artist_names = nil
    if params[:input]
      if cacheout
        logger.debug("Fetched artist name autosuggest tags from cache")
        artist_names = ActiveSupport::JSON.decode cacheout
      end
      unless artist_names
        all_names = Artist.active.map(&:fullname)
        artist_names = Artist.active.map{|a| { 'value' => a.fullname, 'info' => a.id } }
        cachein = ActiveSupport::JSON.encode artist_names
        if cachein
          SafeCache.write(AUTOSUGGEST_CACHE_KEY, cachein, :expires_in => AUTOSUGGEST_CACHE_EXPIRY)
        end
      end
      if params[:input].present?
        # filter with input prefix
        inp = params[:input].downcase
        lin = inp.length - 1
        begin
          artist_names = artist_names.compact.delete_if {|nm| inp != nm['value'][0..lin].downcase}
        rescue Exception => ex
          artist_names = []
        end
      end
    end
    render :json => artist_names
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
    Messager.new.publish "/artists/#{current_artist.id}/art_pieces/delete", "deleted art pieces"
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
    if params.has_key? :neworder
      # new endpoint for rearranging - more than just setting representative
      neworder = params[:neworder].split(',')
      begin
        neworder.each_with_index do |apid, idx|
          a = ArtPiece.find(apid)
          a.update_attribute(:order, idx)
        end
        flash[:notice] = "Your images have been reordered."
        Messager.new.publish "/artists/#{current_artist.id}/art_pieces/arrange", "reordered art pieces"
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
    @artist = get_artist_from_params
    set_artist_meta
    respond_to do |format|
      format.html {
        @artist = ArtistPresenter.new(view_context, @artist)
        store_location
        render :action => 'show', :layout => 'mau'
      }
      format.json  {
        cleaned = @artist.clean_for_export(@art_pieces)
        render :json => cleaned
      }
      format.mobile {
        @page_title = "Artist: " + (@artist ? @artist.get_name(true) : '')
        render :layout => 'mobile'
      }
    end
  end

  def bio

    @artist = get_artist_from_params
    set_artist_meta

    if @artist.bio.present?
      respond_to do |format|
        format.html { redirect_to artist_path(@artist) and return }
        format.mobile {
          @page_title = "Artist: " + (@artist ? @artist.get_name(true) : '')
          render :layout => 'mobile'
        }
      end
    else
      redirect_to artist_path(@artist)
    end
  end

  def qrcode
    @artist = get_artist_from_params
    if @artist
      qrcode_system_path = @artist.qrcode
      respond_to do |fmt|
        fmt.html {
          redirect_to "/artistdata/#{@artist.id}/profile/qr.png"
        }
        fmt.png {
          data = File.open(qrcode_system_path,'rb').read
          send_data(data, :filename => 'qr.png', :type=>'image/png', :disposition => "inline")
        }
      end
    else
      render :action => 'show', :layout => 'mau'
    end
  end

  def update
    if request.xhr?
      if params.has_key?(:artist_os_participation)
        participating = (params[:artist_os_participation].to_i != 0)
        if participating != current_artist.artist_info.os_participation[Conf.oslive]
          begin
            unless current_artist.address.blank?
              ai = current_artist.artist_info
              ai.update_os_participation(Conf.oslive, participating)
              OpenStudiosSignupEvent.create(:message => "#{current_artist.fullname} set their os status to #{participating} for #{Conf.oslive} open studios",
                                            :data => {'user' => current_artist.login, 'user_id' => current_artist.id})
              ai.save!
            end
          rescue Exception => ex
            puts ex.to_s
          end
        end
      end
      Messager.new.publish "/artists/#{current_artist.id}/update", "updated os info"
      render :json => {:success => true}
    else
      if commit_is_cancel
        redirect_to user_path(current_user)
        return
      end
      begin
        if params[:emailsettings]
          em = params[:emailsettings]
          em = Hash[em.map{|k,v| [k, !!v.to_i]}]
          params[:artist][:email_attrs] = em.to_json
        end
        artist_info = params[:artist].delete :artist_info
        current_artist.artist_info.update_attributes!(artist_info)
        current_artist.update_attributes!(params[:artist])
        flash[:notice] = "Update successful"
        Messager.new.publish "/artists/#{current_artist.id}/update", "updated artist info"

        redirect_to edit_artist_url(current_user)
      rescue Exception => ex
        puts "EX", ex
        flash[:error] = ex.to_s
        redirect_to edit_artist_url(current_user)
      end
    end
  end

  # for mobile only
  def osthumbs
    fetch_thumbs true
    respond_to do |format|
      format.html { redirect_to root_path }
      format.mobile {
        if params[:partial]
          render :thumbs, :layout => false
        else
          render :thumbs, :layout => 'mobile'
        end
      }
    end
  end

  def thumbs
    fetch_thumbs
    respond_to do |format|
      format.html { redirect_to root_path }
      format.mobile {
        if params[:partial]
          render :layout => false
        else
          render :layout => 'mobile'
        end
      }
    end
  end

  protected
  def fetch_thumbs(osonly = false)
    page = params[:page] || 1
    paginate_options = {:page => page, :per_page => 20 }
    if osonly
      @artists = Artist.active.open_studios_participants.with_representative_image.paginate paginate_options
    else
      @artists = Artist.active.with_representative_image.paginate paginate_options
    end
    @artists
  end

  def safe_find_artist(id)
    begin
      Artist.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The artist you were looking for was not found."
      return nil
    end
  end

  def set_artist_meta
    return if !@artist
    @page_title = "Mission Artists United - Artist: %s" % @artist.get_name
    @page_description = build_page_description @artist
    @page_keywords += [@artist.media.map(&:name), @artist.tags.map(&:name)].flatten.compact.uniq
  end

  def get_artist_from_params
    artist = nil
    begin
      use_id = Integer(params[:id])
    rescue ArgumentError
      use_id = false
    end
    if !use_id
      artist = Artist.find_by_login(params[:id])
      if !artist or artist.suspended?
        artist = nil
        flash.now[:error] = "The artist '" + params[:id] + "' you were looking for was not found."
      end
    else
      artist = safe_find_artist(params[:id])
      if artist && artist.suspended?
        flash.now[:error] = "The artist '" + artist.get_name(true) + "' is no longer with us."
        artist = nil
      end
    end
    artist
  end

  def build_page_description artist
    if (artist)
      trim_bio = (artist.bio || '').truncate(500)
      if trim_bio.present?
        return "Mission Artists United Artist : #{artist.get_name(true)} : " + trim_bio
      end
    end
    @page_description
  end

  private
  def is_os_only(osonly)
    [true, "1",1,"on","true"].include? osonly
  end

end
