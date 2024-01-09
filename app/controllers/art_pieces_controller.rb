class ArtPiecesController < ApplicationController
  include TagsHelper

  before_action :user_required, only: %i[edit update create destroy]
  before_action :artist_required, only: %i[edit update create destroy]
  before_action :load_art_piece, only: %i[show destroy edit update]
  before_action :load_media, only: %i[edit create update]

  def show
    respond_to do |format|
      format.html do
        set_page_info_from_art_piece
        @art_piece = ArtPieceHtmlPresenter.new(@art_piece)
        render 'show'
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
    redirect_to(current_artist) && return if commit_is_cancel

    art_piece = CreateArtPieceService.call(current_artist, art_piece_params)

    if art_piece&.persisted?
      flash[:notice] = "You've got new art!"
      redirect_to art_piece
    else
      @art_piece = art_piece
      @artist = ArtistPresenter.new(current_artist)
      render 'artists/manage_art'
    end
  end

  # PUT /art_pieces/1
  def update
    redirect_to(@art_piece) && return if !owned_by_current_user?(@art_piece) || commit_is_cancel

    @art_piece = UpdateArtPieceService.new(@art_piece, art_piece_params).update_art_piece
    if @art_piece.valid?
      flash[:notice] = 'The art has been updated.'
      redirect_to art_piece_path(@art_piece)
    else
      render 'edit'
    end
  end

  # DELETE /art_pieces/1
  # DELETE /art_pieces/1.xml
  def destroy
    artist = @art_piece.artist
    if owned_by_current_user?(@art_piece)
      @art_piece.destroy
      BryantStreetStudiosWebhook.artist_updated(@art_piece.artist.id)
    end
    redirect_to(artist)
  end

  protected

  def load_media
    @media ||= Medium.alpha
  end

  def set_page_info_from_art_piece
    @page_title = PageInfoService.title(sprintf('Artist: %s', @art_piece.artist.get_name))
    @page_image = @art_piece.image(:large)
    @page_description = (build_page_description @art_piece) || @page_description
    @page_keywords += [@art_piece.tags + [@art_piece.medium]].flatten.compact.map(&:name)
  end

  def owned_by_current_user?(art_piece)
    (art_piece.artist == current_user)
  end

  def load_art_piece
    @art_piece = safe_find_art_piece(params[:id])
    return if @art_piece&.artist && @art_piece.artist.active?

    flash[:error] = "We couldn't find that art piece."
    redirect_to '/error'
  end

  def safe_find_art_piece(id)
    ArtPiece.find_by(id:)
  end

  def build_page_description(art_piece)
    HtmlEncoder.encode("Mission Artists Art : #{art_piece.title} by #{art_piece.artist.full_name}") if art_piece
  end

  def art_piece_params
    params.require(:art_piece).permit(
      :description,
      :dimensions,
      :medium,
      :medium_id,
      :photo,
      :position,
      :price,
      :sold,
      :tags,
      :title,
      :year,
      tag_ids: [],
    )
  end
end
