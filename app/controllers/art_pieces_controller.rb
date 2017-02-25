# frozen_string_literal: true
class ArtPiecesController < ApplicationController
  include TagsHelper

  before_action :user_required, only: [ :new, :edit, :update, :create, :destroy]
  before_action :artist_required, only: [ :new, :edit, :update, :create, :destroy]
  before_action :load_art_piece, only: [:show, :destroy, :edit, :update]
  before_action :load_media, only: [:new, :edit, :create, :update]

  after_action :flush_cache, only: [:create, :update, :destroy]

  def flush_cache
    Medium.flush_cache
    ArtPieceTagService.flush_cache
  end

  def show
    respond_to do |format|
      format.html do
        set_page_info_from_art_piece
        @art_piece = ArtPieceHtmlPresenter.new(@art_piece)
        render action: 'show'
      end
      format.json do
        redirect_to api_v2_art_piece_path(@art_piece, format: :json)
      end
    end
  end

  # GET /art_pieces/1/edit
  def edit
    redirect_to '/error' unless owned_by_current_user?(@art_piece)
  end

  def create
    redirect_to(current_artist) and return if commit_is_cancel

    art_piece = CreateArtPieceService.new(current_artist, art_piece_params).create_art_piece
    if art_piece.valid?
      flash[:notice] = "You've got new art!"
      Messager.new.publish "/artists/#{current_artist.id}/art_pieces/create", "added art piece"
      redirect_to art_piece
    else
      @art_piece = art_piece
      @artist = ArtistPresenter.new(current_artist)
      render template: 'artists/manage_art'
    end
  end

  # PUT /art_pieces/1
  def update
    redirect_to @art_piece and return if !owned_by_current_user?(@art_piece) || commit_is_cancel

    @art_piece = UpdateArtPieceService.new(@art_piece, art_piece_params).update_art_piece
    if @art_piece.valid?
      flash[:notice] = 'The art has been updated.'
      Messager.new.publish "/artists/#{current_artist.id}/art_pieces/update", "updated art piece #{@art_piece.id}"
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
    @page_title = PageInfoService.title("Artist: %s" % @art_piece.artist.get_name)
    @page_image = @art_piece.photo.url(:large)
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

  def build_page_description(art_piece)
    return "Mission Artists Art : #{art_piece.title} by #{art_piece.artist.get_name(true)}" if art_piece
  end

  def art_piece_params
    params.require(:art_piece).permit(:title, :dimensions,
                                      :year, :medium, :medium_id,
                                      :description, :position, :photo, :tags)
  end
end
