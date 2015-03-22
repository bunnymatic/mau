require 'csv'
require 'xmlrpc/client'

Mime::Type.register "image/png", :png

class ArtistsController < ApplicationController

  include HtmlHelper

  # Be sure to include AuthenticationSystem in Application Controller instead
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['artist_names']['cache_key']
  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['artist_names']['cache_exipry']

  before_filter :user_required, only: [ :edit, :update, :manage_art, :delete_art, :destroyart, :setarrangement, :arrange_art ]

  def index
    respond_to do |format|
      format.html {
        # collect query args to build links
        @os_only = is_os_only(params[:osonly])

        cur_page = (params[:p] || 0).to_i
        filter = params[:filter]
        # build alphabetical list keyed by first letter
        @gallery = ArtistsGallery.new(@os_only, cur_page, filter)

        @page_title = "Mission Artists United - MAU Artists"
        set_artists_index_links

        if request.xhr?
          render partial: 'artist_list', locals: { gallery: @gallery }
        else
          render action: 'index'
        end
      }
      format.json {
        render json: Artist.active
      }
    end
  end

  def map_page
    @os_only = is_os_only(params["osonly"])

    set_artists_index_links

    @map_info = ArtistsMap.new(@os_only)

    render :map
  end

  def edit
    if current_user[:type] != 'Artist'
      redirect_to edit_user_path(current_user), flash: flash
      return
    end
    @user = ArtistPresenter.new(current_artist)
    @studios = Studio.all
    @artist_info = current_user.artist_info || ArtistInfo.new({ id: current_user.id })
    @openstudios_question = CmsDocument.packaged(:artists_edit, :openstudios_question)
  end

  def manage_art
    @art_piece = current_artist.art_pieces.build
    # give user a tabbed page to edit their art
    @artist = ArtistPresenter.new(current_artist)
  end


  def roster
    # collect query args to build links
    @os_only = is_os_only(params[:osonly])

    @roster = ArtistsRoster.new(@os_only)

    @page_title = "Mission Artists United - MAU Artists"
    set_artists_index_links

    render action: 'roster'
  end

  def suggest
    # grab all names from the cache
    names = fetch_artists_for_autosuggest
    inp = (params[:input] || params[:q]).try(:downcase)
    if inp
      # filter with input prefix
      names = (inp.present? ? names.select{|name| name['value'] && name['value'].downcase.include?(inp)} : [])
    end
    render json: names
  end

  def destroyart
    # receives post from delete art form
    unless params[:art]
      redirect_to(artist_path(current_user)) and return
    end

    ids = params[:art].map { |kk,vv| kk if vv != "0" }.compact
    arts = ArtPiece.where(id: ids, artist_id: current_user.id)
    arts.each do |art|
      art.destroy
    end
    Messager.new.publish "/artists/#{current_artist.id}/art_pieces/delete", "deleted art pieces"
    redirect_to(artist_path(current_user))
  end

  def arrange_art
    @artist = ArtistPresenter.new(current_user)
  end

  def setarrangement
    if params.has_key? :neworder
      # new endpoint for rearranging - more than just setting representative
      neworder = params[:neworder].split(',')
      neworder.each_with_index do |apid, idx|
        a = ArtPiece.where(id: apid, artist_id: current_user.id).first
        a.update_attribute(:order, idx) if a
      end
      flash[:notice] = "Your images have been reordered."
      Messager.new.publish "/artists/#{current_artist.id}/art_pieces/arrange", "reordered art pieces"
    else
      flash[:error] ="There was a problem interpreting the input parameters.  Please try again."
    end
    redirect_to user_path(current_user)
  end

  def delete_art
    @artist = ArtistPresenter.new(current_user)
  end

  def show
    @artist = get_active_artist_from_params
    set_artist_meta
    respond_to do |format|
      format.html {
        if !@artist
          redirect_to artists_path, flash: { error: 'We were unable to find the artist you were looking for.' }
        else
          @artist = ArtistPresenter.new( @artist)
        end
      }
      format.json  {
        render json: @artist
      }
    end
  end

  def qrcode
    @artist = get_active_artist_from_params
    if @artist
      qrcode_system_path = @artist.qrcode
      respond_to do |fmt|
        fmt.html {
          redirect_to "/artistdata/#{@artist.id}/profile/qr.png"
        }
        fmt.png {
          data = File.open(qrcode_system_path,'rb').read
          send_data(data, filename: 'qr.png', :type=>'image/png', disposition: "inline")
        }
      end
    else
      render action: 'show'
    end
  end

  def update
    if request.xhr?
      process_os_update
      render json: {success: true, os_status: current_artist.reload.doing_open_studios?}
    else
      if commit_is_cancel
        redirect_to user_path(current_user)
        return
      end
      begin
        current_artist.update_attributes!(artist_params)
        flash[:notice] = "Your profile has been updated"
        Messager.new.publish "/artists/#{current_artist.id}/update", "updated artist info"
      rescue Exception => ex
        puts "EX", ex
        flash[:error] = ex.to_s
        raise
      end
      redirect_to edit_artist_url(current_user), flash: flash
    end
  end

  protected
  def safe_find_artist(id)
    Artist.where(id: id).first || Artist.where(login: id).first
  end

  def set_artist_meta
    return if !@artist
    @page_title = "Mission Artists United - Artist: %s" % @artist.get_name
    @page_description = build_page_description @artist
    @page_keywords += [@artist.media.map(&:name), @artist.tags.map(&:name)].flatten.compact.uniq
  end

  def get_active_artist_from_params
    artist = safe_find_artist(params[:id])
    if artist && !artist.active?
      flash.now[:error] = "The artist '" + artist.get_name(true) + "' is no longer with us."
      artist = nil
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
  def artist_params
    if params[:emailsettings]
      em = params[:emailsettings]
      em = Hash[em.map{|k,v| [k, !!v.to_i]}]
      params[:artist][:email_attrs] = em.to_json
    end

    if params[:artist].has_key?("studio") && params[:artist]["studio"].blank?
      params[:artist]["studio_id"] = nil
      params[:artist].delete("studio")
    end

    params[:artist]
  end

  def is_os_only(osonly)
    [true, "1",1,"on","true"].include? osonly
  end

  def set_artists_index_links
    os_args = (@os_only ? {osonly: 'on'} : {})
    @roster_link = roster_artists_url(os_args)
    @gallery_link = artists_url(os_args)
    @map_link = map_artists_path(os_args)
  end

  def fetch_artists_for_autosuggest
    artist_names = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    unless artist_names
      artist_names = Artist.active.map{|a| { 'value' => a.get_name(true), 'info' => a.id } }
      if artist_names.present?
        SafeCache.write(AUTOSUGGEST_CACHE_KEY, artist_names, expires_in: AUTOSUGGEST_CACHE_EXPIRY)
      end
    end
    artist_names
  end

  # process xhr request to update artist os participation
  def process_os_update
    participating = (((params[:artist] && params[:artist][:os_participation])).to_i != 0)
    if participating != current_artist.doing_open_studios?
      begin
        unless current_artist.address.blank?
          current_artist.update_os_participation(OpenStudiosEvent.current, participating)
          trigger_os_signup_event(participating)
        end
      rescue Exception => ex
        puts ex.to_s
      end
    end
    Messager.new.publish "/artists/#{current_artist.id}/update", "updated os info"
  end

  def trigger_os_signup_event(participating)
    msg = "#{current_artist.fullname} set their os status to"+
      " #{participating} for #{current_open_studios_key} open studios"
    data = {'user' => current_artist.login, 'user_id' => current_artist.id}
    OpenStudiosSignupEvent.create(message: msg,
                                  data: data)
  end

end
