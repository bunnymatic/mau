# frozen_string_literal: true

require 'csv'

Mime::Type.register 'image/png', :png

class ArtistsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['artist_names']['cache_key']
  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['artist_names']['cache_exipry']

  before_action :user_required, only: %i[register_for_current_open_studios my_profile
                                         edit update manage_art delete_art
                                         destroyart setarrangement arrange_art]
  def index
    respond_to do |format|
      format.html do
        # collect query args to build links
        @os_only = os_only?(params[:o])
        cur_page = (params[:p] || 0).to_i
        cur_sort = params[:s] || :lastname
        @letters = ArtistsGallery.letters(cur_sort)
        cur_letter = params[:l] || @letters.first

        # build alphabetical list keyed by first letter
        @gallery = ArtistsGallery.new(@os_only, cur_letter, cur_sort, cur_page)
        @page_title = PageInfoService.title('Artists')
        if request.xhr?
          render partial: 'artist_list', locals: { gallery: @gallery }
        else
          render 'index'
        end
      end
      format.json do
        head(403)
      end
    end
  end

  def register_for_current_open_studios
    unless current_user.artist?
      flash[:error] = "You must have an Artist's account, not a Fan account"\
                      ' to see that page you requested.  Please login as an '\
                      'Artist and try again.'
      redirect_to user_path(current_user)
      return
    end
    redirect_to(edit_artist_path(current_user, anchor: 'events'),
                flash: { registering_for_open_studios: true })
  end

  def update_os_status_message(status, artist, os_event)
    if !status
      "You're account needs more info before you can "\
      'register for Open Studios (probably an address or studio).'
    else
      "Thanks for participating in Open Studios #{os_event.for_display(true)}!\n"\
      "Please confirm your studio address: #{artist.address}.\n"\
      "Look for an email with more info.\n"\
      "It's FREE to participate, we are completely donation and volunteer supported."
    end
  end

  def my_profile
    redirect_to edit_artist_path(current_user, anchor: 'events')
  end

  def edit
    redirect_to(edit_user_path(current_user)) && return unless current_user.artist?

    @user = ArtistPresenter.new(current_artist)
    @studios = StudioService.all
    @artist_info = current_artist.artist_info || ArtistInfo.new(id: current_artist.id)
    @open_studios_event = OpenStudiosEventPresenter.new(OpenStudiosEvent.current)
  end

  def manage_art
    @art_piece = current_artist.art_pieces.build
    # give user a tabbed page to edit their art
    @artist = ArtistPresenter.new(current_artist)
  end

  def roster
    # collect query args to build links
    @os_only = os_only?(params[:o])

    @roster = ArtistsRoster.new(@os_only)

    @page_title = PageInfoService.title('Artists')

    render 'roster'
  end

  def suggest
    # grab all names from the cache
    names = fetch_artists_for_autosuggest
    inp = (params[:input] || params[:q]).try(:downcase)
    if inp
      # filter with input prefix
      names = (inp.present? ? names.select { |name| /#{inp}/i =~ name['value'] } : [])
    end
    render json: names, adapter: :json_api
  end

  def destroyart
    # receives post from delete art form
    redirect_to(artist_path(current_user)) && return unless destroy_art_params

    ids = destroy_art_params.reject { |_kk, vv| vv == '0' }.keys
    ArtPiece.where(id: ids, artist_id: current_user.id).destroy_all
    Messager.new.publish "/artists/#{current_artist.id}/art_pieces/delete", 'deleted art pieces'
    redirect_to(artist_path(current_user))
  end

  def arrange_art
    @artist = ArtistPresenter.new(current_user)
  end

  def setarrangement
    if params.key? :neworder
      # new endpoint for rearranging - more than just setting representative
      neworder = params[:neworder].split(',')
      neworder.each_with_index do |apid, idx|
        a = ArtPiece.where(id: apid, artist_id: current_user.id).first
        a&.update(position: idx)
      end
      Messager.new.publish "/artists/#{current_artist.id}/art_pieces/arrange", 'reordered art pieces'
    else
      flash[:error] = 'There was a problem interpreting the input parameters.  Please try again.'
    end
    if request.xhr?
      render json: true
    else
      flash[:notice] = 'Your images have been reordered.'
      redirect_to artist_path(current_user)
    end
  end

  def delete_art
    @artist = ArtistPresenter.new(current_user)
  end

  def show
    @artist = active_artist_from_params
    respond_to do |format|
      format.html do
        if !@artist
          redirect_to artists_path, error: 'We were unable to find the artist you were looking for.'
        else
          @artist = ArtistPresenter.new(@artist)
          set_artist_meta
        end
      end
      format.json do
        render json: @artist
      end
    end
  end

  def update
    if request.xhr?
      open_studios_event = OpenStudiosEvent.current
      os_status = UpdateArtistService.new(current_artist, os_status_params).update_os_status
      message = update_os_status_message(os_status, current_artist, open_studios_event)
      render json: {
        success: true,
        os_status: os_status,
        current_os: OpenStudiosEventService.current,
        message: message,
      }
    else
      if commit_is_cancel
        redirect_to user_path(current_user)
        return
      end
      if UpdateArtistService.new(current_artist, artist_params).update
        Messager.new.publish "/artists/#{current_artist.id}/update", 'updated artist info'
        flash[:notice] = 'Your profile has been updated'
        redirect_to edit_artist_url(current_user)
      else
        @user = ArtistPresenter.new(current_artist.reload)
        @studios = StudioService.all
        render :edit
      end
    end
  end

  protected

  def safe_find_artist(id)
    Artist.friendly.find id
  rescue ActiveRecord::RecordNotFound
    nil
  end

  def set_artist_meta
    return unless @artist

    @page_title = PageInfoService.title(sprintf('Artist: %s', @artist.get_name))
    @page_image = @artist.get_profile_image(:large) if @artist.profile_image?
    @page_description = build_page_description @artist
    @page_keywords += @artist.media_and_tags + (@page_keywords || [])
  end

  def active_artist_from_params
    artist = safe_find_artist(params[:id])
    if artist && !artist.active?
      flash.now[:error] = "The artist '" + artist.get_name(true) + "' is no longer with us."
      artist = nil
    end
    artist
  end

  def build_page_description(artist)
    if artist
      trim_bio = (artist.bio || '').truncate(500)
      return "Mission Artists Artist : #{artist.get_name(true)} : " + trim_bio if trim_bio.present?
    end
    @page_description
  end

  private

  def destroy_art_params
    if params.key? :art
      params.require(:art).permit!
    else
      params
    end
  end

  def os_status_params
    params.require(:artist).permit('os_participation')
  end

  def artist_info_permitted_attributes
    %i[bio street city addr_state zip studionumber]
  end

  def artist_params
    if params[:artist].key?('studio') && params[:artist]['studio'].blank?
      params[:artist]['studio_id'] = nil
      params[:artist].delete('studio')
    end

    permitted = %i[
      studio
      login
      email
      password
      password_confirmation
      photo
      firstname
      lastname
      url
      studio_id
      studio
      nomdeplume
    ] + User.stored_attributes[:links]
    params
      .require(:artist)
      .permit(*permitted, artist_info_attributes: artist_info_permitted_attributes)
  end

  def os_only?(osonly)
    [true, '1', 1, 'on', 'true'].include? osonly
  end

  def fetch_artists_for_autosuggest
    artist_names = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    unless artist_names
      artist_names = Artist.active.map do |a|
        name = a.get_name(true)
        { 'value' => a.get_name(true), 'info' => a.id } if name.present?
      end.compact
      SafeCache.write(AUTOSUGGEST_CACHE_KEY, artist_names, expires_in: AUTOSUGGEST_CACHE_EXPIRY) if artist_names.present?
    end
    artist_names
  end
end
