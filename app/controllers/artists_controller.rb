# frozen_string_literal: true
require 'csv'
require 'xmlrpc/client'

Mime::Type.register 'image/png', :png

class ArtistsController < ApplicationController
  # Be sure to include AuthenticationSystem in Application Controller instead
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['artist_names']['cache_key']
  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['artist_names']['cache_exipry']

  before_action :user_required, only: [:my_profile, :edit, :update, :manage_art, :delete_art,
                                       :destroyart, :setarrangement, :arrange_art]

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
          render action: 'index'
        end
      end
      format.json do
        head(403)
      end
    end
  end

  def my_profile
    redirect_to edit_artist_path(current_user)
  end

  def edit
    redirect_to(edit_user_path(current_user)) && return unless current_user.artist?
    @user = ArtistPresenter.new(current_artist)
    @studios = StudioService.all
    @artist_info = current_artist.artist_info || ArtistInfo.new(id: current_artist.id)
    @openstudios_question = CmsDocument.packaged(:artists_edit, :openstudios_question)
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

    render action: 'roster'
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
    ids = destroy_art_params.select { |_kk, vv| vv != '0' }.keys
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
        a&.update_attribute(:position, idx)
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

  # TODO: use paperclip to save the qr code
  # def qrcode
  #   @artist = active_artist_from_params
  #   if @artist
  #     qrcode_system_path = @artist.qrcode
  #     respond_to do |fmt|
  #       fmt.html {
  #         redirect_to "/artistdata/#{@artist.id}/profile/qr.png"
  #       }
  #       fmt.png {
  #         data = File.open(qrcode_system_path,'rb').read
  #         send_data(data, filename: 'qr.png', :type=>'image/png', disposition: "inline")
  #       }
  #     end
  #   else
  #     render action: 'show'
  #   end
  # end

  def update
    if request.xhr?
      os_status = UpdateArtistService.new(current_artist, artist_params).update_os_status
      render json: { success: true, os_status: os_status, current_os: OpenStudiosEventService.current }
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
      if trim_bio.present?
        return "Mission Artists Artist : #{artist.get_name(true)} : " + trim_bio
      end
    end
    @page_description
  end

  private

  def artist_info_permitted_attributes
    %i(bio street city addr_state zip studionumber)
  end

  def destroy_art_params
    if params.key? :art
      params.require(:art).permit!
    else
      params
    end
  end

  def artist_params
    if params[:artist].key?('studio') && params[:artist]['studio'].blank?
      params[:artist]['studio_id'] = nil
      params[:artist].delete('studio')
    end

    permitted = [:studio, :login, :email,
                 :password, :password_confirmation, :photo, :os_participation,
                 :firstname, :lastname, :url, :studio_id, :studio, :nomdeplume] + User.stored_attributes[:links]
    params.require(:artist).permit(*permitted, artist_info_attributes: artist_info_permitted_attributes)
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
      if artist_names.present?
        SafeCache.write(AUTOSUGGEST_CACHE_KEY, artist_names, expires_in: AUTOSUGGEST_CACHE_EXPIRY)
      end
    end
    artist_names
  end
end
