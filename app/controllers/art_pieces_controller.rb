class ArtPiecesController < ApplicationController

  include TagsHelper
  include HtmlHelper

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
    render json: artist.art_pieces, root: false
  end

  def show
    respond_to do |format|
      format.html {
        set_page_info_from_art_piece
        @art_piece = ArtPieceHtmlPresenter.new(@art_piece)
        render action: 'show'
      }
      format.json {
        redirect_to api_v2_art_piece_path(@art_piece, format: :json)
      }
    end

  end

  # GET /art_pieces/1/edit
  def edit
    redirect_to '/error' unless owned_by_current_user?(@art_piece)
  end

  def create
    artist = current_artist
    redirect_to(artist) and return if commit_is_cancel

    prepare_tags_params
    art_piece = artist.art_pieces.build(art_piece_params)
    if art_piece.save
      flash[:notice] = "You've got new art!"
      Messager.new.publish "/artists/#{artist.id}/art_pieces/create", "added art piece"
      redirect_to artist
    else
      @art_piece = art_piece
      @artist = ArtistPresenter.new(artist)
      render template: 'artists/manage_art'
    end



    # if file to upload - upload it first
    # upload = params[:upload]
    # if !params[:upload]
    #   @artist = ArtistPresenter.new(artist)
    #   create_art_piece_failed_empty_image(art_piece) and return
    # end

    # begin
    #   ActiveRecord::Base.transaction do
    #     if valid
    #       # upload image
    #       ArtPieceImage.new(art_piece).save upload
    #       art_piece.save!
    #       flash[:notice] = "You've got new art!"
    #       Messager.new.publish "/artists/#{artist.id}/art_pieces/create", "added art piece"
    #     else
    #       @artist = ArtistPresenter.new(artist)
    #       create_art_piece_failed(art_piece) and return
    #     end
    #   end
    # rescue Exception => ex
    #   @artist = ArtistPresenter.new(artist)
    #   create_art_piece_failed_upload(art_piece) and return
    # end
    # redirect_to(artist)
  end

  # PUT /art_pieces/1
  def update
    if commit_is_cancel || (@art_piece.artist != current_user)
      redirect_to @art_piece and return
    end
    prepare_tags_params
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

  def build_page_description art_piece
    return "Mission Artists United Art : #{art_piece.title} by #{art_piece.artist.get_name(true)}" if art_piece
  end

  def prepare_tags_params
    tags_string = params[:art_piece][:tags]
    tag_names = (tags_string || '').split(",").map{|name| name.strip.downcase}.compact.uniq
    params[:art_piece][:tags] = tag_names.map{|name| ArtPieceTag.find_or_create_by(name: name)}
  end

  def art_piece_params
    parameters = params.require(:art_piece).permit(:title, :dimensions, :year, :medium, :medium_id, :description, :position, :photo)
    if params[:art_piece][:tags]
      parameters.merge({tags: params[:art_piece][:tags]})
    else
      parameters
    end
  end


  def create_art_piece_failed_empty_image(art_piece)
    @art_piece = art_piece
    art_piece.errors.add(:base, "You must provide an image.  "+
                                 "Image filenames need to be simple.  Some characters can cause issues with your upload,"+
                                 " like quotes \", apostrophes \' or brackets ([{}]).".html_safe)
    render template: 'artists/manage_art'
  end

  def create_art_piece_failed_upload(art_piece)
    @art_piece = art_piece
    msg = "Failed to upload %s" % $!
    art_piece.errors.add(:base, msg)
    render template: 'artists/manage_art'
  end

  def create_art_piece_failed(art_piece)
    @art_piece = art_piece
    render template: 'artists/manage_art'
  end


end
