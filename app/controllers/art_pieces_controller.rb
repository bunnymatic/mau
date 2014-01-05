require 'json'
class ArtPiecesController < ApplicationController

  include TagsHelper
  include HtmlHelper

  layout 'mau1col', :except => :show

  before_filter :admin_required, :only => [ :index, ]
  before_filter :login_required, :only => [ :new, :edit, :update, :create, :destroy]
  before_filter :artist_required, :only => [ :new, :edit, :update, :create, :destroy]
  before_filter :load_art_piece, :only => [:show, :destroy, :edit, :update] 
  
  after_filter :flush_cache, :only => [:create, :update, :destroy]
  after_filter :store_location

  def flush_cache
    Medium.flush_cache
    ArtPieceTag.flush_cache
  end

  def show
    @facebook_required = true
    @pinterest_required = true && !browser.ie6? && !browser.ie7? && !browser.ie8?

    if is_mobile?
      redirect_to artist_path(@art_piece.artist) and return
    end
    
    set_page_info_from_art_piece

    respond_to do |format|
      format.html {
        @thumb_browser = ThumbnailBrowserPresenter.new(view_context, @art_piece.artist, @art_piece)
        @art_piece = ArtPieceHtmlPresenter.new(view_context, @art_piece)
        render :action => 'show', :layout => 'mau'
      }
      format.json {
        art_piece = ArtPieceJsonPresenter.new(@art_piece)
        render :json => art_piece.to_json
      }
    end

  end

  def new
    artist = Artist.find(current_user.id)
    cur_pieces = artist.art_pieces.length
    if cur_pieces >= artist.max_pieces
      flash.now[:error] = "You cannot have more than %s art pieces.  "+
        "If you decide to continue adding art, the oldest pieces will "+
        "be removed to make space for the new ones.  Alternatively, you "+
        "could go delete specific pieces to make room for the new ones." % artist.max_pieces
    end
    @art_piece = ArtPiece.new
    @media = Medium.all
  end

  # GET /art_pieces/1/edit
  def edit
    if !owned_by_current_user?(@art_piece)
      flash[:error] = "You're not allowed to edit that work."
      redirect_to "/error"
    end
    @media = Medium.all
    @selected_medium = @art_piece.medium
  end

  def create
    if commit_is_cancel
      redirect_to(current_user)
      return
    end
    @media = Medium.all

    # if file to upload - upload it first
    @errors = []
    upload = params[:upload]
    saved = false
    if !upload
      flash.now[:error] = "You must provide an image.<br/>"+
        "Image filenames need to be simple.  Some characters can cause issues with your upload,"+
        " like quotes &quot;, apostrophes &apos; or brackets ([{}]).".html_safe
      @art_piece = ArtPiece.new params[:art_piece]
      render :action => 'new'
      return
    else
      params[:art_piece][:art_piece_tags] = tags_from_s(params[:tags])
      @art_piece = current_user.art_pieces.build(params[:art_piece])
      begin
        ActiveRecord::Base.transaction do
          saved = @art_piece.save
          if saved
            # upload image
            if upload
              post = ArtPieceImage.new(@art_piece, upload).save
            end
            flash[:notice] = 'Artwork was successfully added.'
            Messager.new.publish "/artists/#{current_user.id}/art_pieces/create", "added art piece"
          else
            @errors = @art_piece.errors.full_messages
            @art_piece = ArtPiece.new params[:art_piece]
          end
        end
      rescue Exception => ex
        puts ex
        puts ex.backtrace
        @errors << "%s" % ex.message
        logger.error("Failed to upload %s" % $!)
        @art_piece = ArtPiece.new params[:art_piece]
        render :action => 'new'
        return
      end
    end

    if saved
      redirect_to(current_user)
    else
      @media = Medium.all
      render :action => "new"
    end
  end

  # PUT /art_pieces/1
  def update
    if commit_is_cancel
      @thumb_browser = ThumbnailBrowserPresenter.new(view_context, @art_piece.artist, @art_piece)
      @art_piece = ArtPiecePresenter.new(view_context, @art_piece)
      render :action => 'show', :layout => 'mau'
      return
    else
      @media = Medium.all
      begin
        params[:art_piece][:art_piece_tags] = tags_from_s(params[:tags])
        success = @art_piece.update_attributes(params[:art_piece])
      rescue
        logger.warn("Failed to update artpiece : %s" % $!)
        @errors = @art_piece.errors
        @errors.add('ArtPieceTags','%s' % $!)
        render :action => "edit"
        return
      end
      if success
        flash[:notice] = 'Artwork was successfully updated.'
        Messager.new.publish "/artists/#{current_user.id}/art_pieces/update", "updated art piece #{@art_piece.id}"
        redirect_to art_piece_path(@art_piece)
      else
        @errors = art_piece.errors
        if @art_piece.medium
          @selected_medium = @art_piece.medium
        end
        render :action => "edit"
      end
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

  def sidebar_info
  end

  protected

  def set_page_info_from_art_piece
    @page_title = "Mission Artists United - Artist: %s" % @art_piece.artist.get_name
    @page_description = build_page_description @art_piece
    @page_keywords += [@art_piece.art_piece_tags + [@art_piece.medium]].flatten.compact.map(&:name)
  end

  def owned_by_current_user?(art_piece)
    (art_piece.artist == current_user)
  end

  def load_art_piece
    @art_piece = safe_find_art_piece(params[:id])
    if !@art_piece || !@art_piece.artist
      flash[:error] = "We couldn't find that art piece."
      redirect_to "/error"
    end
  end

  def safe_find_art_piece(id)
    begin
      ArtPiece.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "We couldn't find the art you were looking for."
      return nil
    end
  end

  def build_page_description art_piece
    if (art_piece)
      if art_piece && !art_piece.title.empty?
        return "Mission Artists United Art : #{art_piece.title} by #{art_piece.artist.get_name(true)}"
      end
    end
    return @page_description
  end
end
