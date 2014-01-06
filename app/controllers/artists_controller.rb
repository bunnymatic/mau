# -*- coding: utf-8 -*-
require 'csv'
require 'xmlrpc/client'

Mime::Type.register "image/png", :png

class ArtistsController < ApplicationController

  include ArtistsHelper
  include HtmlHelper

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

    @os_only = is_os_only(params["osonly"])

    set_artists_index_links

    @map_info = ArtistsMap.new(view_context, @os_only)

    render :map
  end

  def admin_index
    get_sort_options_from_params
    @artist_list = AdminArtistList.new(view_context, @sort_by, @reverse)
    respond_to do |format|
      format.html { render :layout => 'mau-admin' }
      format.csv { render_csv_string(@artist_list.csv, @artist_list.csv_filename) }
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

  def roster
    # collect query args to build links
    @os_only = is_os_only(params[:osonly])

    @roster = ArtistsRoster.new(view_context, @os_only)

    @page_title = "Mission Artists United - MAU Artists"
    set_artists_index_links

    render :action => 'roster', :layout => 'mau1col'
  end

  def index
    respond_to do |format|
      format.html {
        # collect query args to build links
        @os_only = is_os_only(params[:osonly])

        cur_page = (params[:p] || 0).to_i

        # build alphabetical list keyed by first letter
        @gallery = ArtistsGallery.new(view_context, @os_only, cur_page)

        @page_title = "Mission Artists United - MAU Artists"
        set_artists_index_links

        render :action => 'index', :layout => 'mau1col'
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
    names = fetch_artists_for_autosuggest
    if params[:input]
      # filter with input prefix
      inp = params[:input].downcase
      names = (inp.present? ? names.select{|name| name['value'].downcase.starts_with?(inp)} : [])
    end
    render :json => names
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
        flash[:error] = "There was a problem reordering your images."+
          " You may try again but if the problem persists, please write"+
          " to help@missionartistsunited.org."
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
              msg = "#{current_artist.fullname} set their os status to"+
                " #{participating} for #{Conf.oslive} open studios"
              data = {'user' => current_artist.login, 'user_id' => current_artist.id}
              OpenStudiosSignupEvent.create(:message => msg,
                                            :data => data)
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

  def set_artists_index_links
    os_args = (@os_only ? {:osonly => 'on'} : {})
    @roster_link = roster_artists_url(os_args)
    @gallery_link = artists_url(os_args)
    @map_link = map_artists_path(os_args)
  end

  def fetch_artists_for_autosuggest
    artist_names = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    unless artist_names
      artist_names = Artist.active.map{|a| { 'value' => a.fullname, 'info' => a.id } }
      if artist_names.present?
        SafeCache.write(AUTOSUGGEST_CACHE_KEY, artist_names, :expires_in => AUTOSUGGEST_CACHE_EXPIRY)
      end
    end
    artist_names
  end

  def get_sort_options_from_params
    @sort_by = params[:sort_by] || params[:rsort_by]
    @reverse = params.has_key? :rsort_by
  end
end
