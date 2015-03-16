class ArtPiecesController < ApplicationController

  include TagsHelper
  include HtmlHelper

  skip_before_filter :get_new_art, :get_feeds

  before_filter :user_required, only: [ :new, :edit, :update, :create, :destroy]
  before_filter :artist_required, only: [ :new, :edit, :update, :create, :destroy]
  before_filter :load_art_piece, only: [:show, :destroy, :edit, :update]
  before_filter :load_media, only: [:new, :edit, :create, :update]

  after_filter :flush_cache, only: [:create, :update, :destroy]

  def flush_cache
    Medium.flush_cache
    ArtPieceTag.flush_cache
  end

  def index
    artist = Artist.active.find(params[:artist_id])
    render json: (artist.art_pieces.map{|ap| (ArtPieceJsonPresenter.new ap).to_json()})
  end

  def show
    @facebook_required = true
    @pinterest_required = true && browser.modern?
    @twitter_required = true

    set_page_info_from_art_piece

    respond_to do |format|
      format.html {
        @thumb_browser = ThumbnailBrowserPresenter.new(@art_piece.artist, @art_piece)
        @art_piece = ArtPieceHtmlPresenter.new(@art_piece)
        render action: 'show'
      }
      format.json {
        art_piece = ArtPieceJsonPresenter.new(@art_piece)
        render json: art_piece.to_json
      }
    end

  end

  # GET /art_pieces/1/edit
  def edit
    redirect_to '/error' unless owned_by_current_user?(@art_piece)
  end

  def create
    redirect_to(current_artist) and return if commit_is_cancel

    @artist = ArtistPresenter.new(current_artist)
    @art_piece = current_artist.art_pieces.build(art_piece_params)
    @art_piece.valid?

    
    # if file to upload - upload it first
    upload = params[:upload]
    if !params[:upload]
      @art_piece.errors.add(:base, "You must provide an image.  "+
        "Image filenames need to be simple.  Some characters can cause issues with your upload,"+
        " like quotes \", apostrophes \' or brackets ([{}]).".html_safe)
      render template: 'artists/manage_art' and return
    end

    @art_piece = current_user.art_pieces.build(art_piece_params)
    valid = @art_piece.valid?
    begin
      ActiveRecord::Base.transaction do
        if valid
          # upload image
          ArtPieceImage.new(@art_piece).save upload
          flash[:notice] = "You've got new art!"
          Messager.new.publish "/artists/#{current_user.id}/art_pieces/create", "added art piece"
        else
          render template: 'artists/manage_art' and return
        end
      end
    rescue Exception => ex
      msg = "Failed to upload %s" % $!
      @art_piece.errors.add(:base, msg)
      render template: 'artists/manage_art' and return
    end

    redirect_to(current_user)
  end

  # PUT /art_pieces/1
  def update
    if commit_is_cancel || (@art_piece.artist != current_user)
      redirect_to @art_piece and return
    end

    if @art_piece.update_attributes(art_piece_params)
      flash[:notice] = 'The art has been updated.'
      Messager.new.publish "/artists/#{current_user.id}/art_pieces/update", "updated art piece #{@art_piece.id}"
      redirect_to art_piece_path(@art_piece)
    else
      render action: "edit"
    end
  end

  # DELETE /art_pieces/1
  # DELETE /art_pieces/1.xml
  def destroy
    artist = @art_piece.artist
    if owned_by_current_user?(@art_piece)
      @art_piece.destroy
      Messager.new.publish "/artists/#{artist.id}/art_pieces/delete", "removed art piece #{@art_piece.id}"
    end
    redirect_to(artist)
  end

  protected

  def load_media
    @media ||= Medium.alpha
  end

  def set_page_info_from_art_piece
    @page_title = "Mission Artists United - Artist: %s" % @art_piece.artist.get_name
    @page_description = (build_page_description @art_piece) || @page_description
    @page_keywords += [@art_piece.tags + [@art_piece.medium]].flatten.compact.map(&:name)
  end

  def owned_by_current_user?(art_piece)
    (art_piece.artist == current_user)
  end

  def load_art_piece
    @art_piece = safe_find_art_piece(params[:id])
    if !@art_piece || !@art_piece.artist || !@art_piece.artist.active?
      flash[:error] = "We couldn't find that art piece."
      redirect_to "/error"
    end
  end

  def safe_find_art_piece(id)
    ArtPiece.where(id: id).first
  end

  def build_page_description art_piece
    return "Mission Artists United Art : #{art_piece.title} by #{art_piece.artist.get_name(true)}" if art_piece
  end

  def art_piece_params
    if params[:art_piece][:tags] && params[:art_piece][:tags].is_a?(String)
      params[:art_piece][:tags] = tags_from_s(params[:art_piece][:tags])
    end
    params[:art_piece]
  end

  def artist_params
    params[:id]
  end
end
