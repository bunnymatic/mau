require 'json'
class ArtPiecesController < ApplicationController

  PER_PAGE = 12

  include ArtPiecesHelper
  include TagsHelper
  layout 'mau1col', :except => :show

  before_filter :admin_required, :only => [ :index, ]
  before_filter :login_required, :only => [ :new, :edit, :update, :create, :destroy]

  after_filter :flush_cache, :only => [:create, :update, :destroy]
  after_filter :store_location

  def flush_cache
    Medium.flush_cache
    ArtPieceTag.flush_cache
  end

  def show
    @facebook_required = true
    @pinterest_required = true && !browser.ie6? && !browser.ie7? && !browser.ie8?

    apid = params[:id].to_i
    art_piece = safe_find_art_piece(apid)
    # get all art pieces for this artist
    pieces = []
    if !art_piece || !art_piece.artist
      flash[:error] = "We couldn't find that art piece."
      redirect_to "/error"
      return
    end

    # get favorites
    if is_mobile?
      redirect_to artist_path(art_piece.artist) and return
    end

    # non-mobile

    pieces = art_piece.artist.art_pieces.order('`order` asc, `created_at` desc')

    @page_title = "Mission Artists United - Artist: %s" % art_piece.artist.get_name
    @page_description = build_page_description art_piece
    @page_keywords += [art_piece.art_piece_tags + [art_piece.medium]].flatten.compact.map(&:name)

    @thumb_browser = ThumbnailBrowserPresenter.new(view_context, art_piece.artist, art_piece)

    @art_piece = ArtPiecePresenter.new(view_context, art_piece)
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'mau' }
      format.json {
        h={}
        h['art_piece'] = art_piece.attributes
        # make safe the art_piece entries
        h['art_piece']["art_piece_tags"] = []
        art_piece.art_piece_tags.each { |t|
          h['art_piece']['art_piece_tags'] << t.attributes
        }
        m = art_piece.medium
        if m
          h['art_piece']["medium"] = art_piece.medium.attributes
        end
        [ 'title','dimensions'].each do |k|
          h['art_piece'][k] = HTMLHelper.encode(h['art_piece'][k])
        end
        h['art_piece']['art_piece_tags'].each do |t|
          t['name'] = HTMLHelper.encode(t['name'])
        end

        if (current_user && current_user.id == art_piece.artist.id)
          h['art_piece']['buttons'] = render_to_string :partial => "edit_delete_buttons", :locals => {:art_piece => @art_piece}
        end
        h['art_piece'].merge!(:favorites_count => @favorites_count)
        h['art_piece']['image_dimensions'] = art_piece.compute_dimensions
        h['art_piece']['image_files'] = art_piece.get_paths
        h['art_piece']['artist_name'] = art_piece.artist.get_name(true)
        render :json => h.to_json
      }
    end

  end

  def new
    artist = Artist.find(current_user.id)
    cur_pieces = artist.art_pieces.length
    if cur_pieces >= artist.max_pieces
      flash.now[:error] = "You cannot have more than %s art pieces.  If you decide to continue adding art, the oldest pieces will be removed to make space for the new ones.  Alternatively, you could go delete specific pieces to make room for the new ones." % artist.max_pieces
    end
    @art_piece = ArtPiece.new
    @media = Medium.all
  end

  # GET /art_pieces/1/edit
  def edit
    @art_piece = safe_find_art_piece(params[:id])
    if @art_piece.artist != current_user
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
      flash.now[:error] = "You must provide an image.<br/>Image filenames need to be simple.  Some characters can cause issues with your upload, like quotes &quot;, apostrophes &apos; or brackets ([{}])."
      @art_piece = ArtPiece.new params[:art_piece]
      render :action => 'new'
      return
    else
      params[:art_piece][:art_piece_tags] = TagsHelper.tags_from_s(params[:tags])
      @art_piece = current_user.art_pieces.build(params[:art_piece])
      begin
        ActiveRecord::Base.transaction do
          saved = @art_piece.save
          if saved
            # upload image
            if upload
              post = ArtPieceImage.save(upload, @art_piece)
            end
            flash[:notice] = 'Artwork was successfully added.'
            Messager.new.publish "/artists/#{current_user.id}/art_pieces/create", "added art piece"
          else
            @errors = @art_piece.errors.full_messages
            @art_piece = ArtPiece.new params[:art_piece]
          end
        end
      rescue Exception => ex
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
    art_piece = safe_find_art_piece(params[:id])
    if commit_is_cancel
      @thumb_browser = ThumbnailBrowserPresenter.new(view_context, art_piece.artist, art_piece)
      @art_piece = ArtPiecePresenter.new(view_context, art_piece)
      render :action => 'show', :layout => 'mau'
      return
    else
      @media = Medium.all
      begin
        params[:art_piece][:art_piece_tags] = TagsHelper.tags_from_s(params[:tags])
        success = art_piece.update_attributes(params[:art_piece])
      rescue
        logger.warn("Failed to update artpiece : %s" % $!)
        @errors = art_piece.errors
        @errors.add('ArtPieceTags','%s' % $!)
        @art_piece = art_piece
        render :action => "edit"
        return
      end
      if success
        flash[:notice] = 'Artwork was successfully updated.'
        Messager.new.publish "/artists/#{current_user.id}/art_pieces/update", "updated art piece #{art_piece.id}"
        redirect_to art_piece_path(art_piece)
      else
        @errors = art_piece.errors
        art_piece = safe_find_art_piece(params[:id])
        if art_piece.medium
          @selected_medium = art_piece.medium
        end
        @art_piece = art_piece
        render :action => "edit"
      end
    end
  end

  # DELETE /art_pieces/1
  # DELETE /art_pieces/1.xml
  def destroy
    art = safe_find_art_piece(params[:id])
    artist = art.artist
    if artist.id == current_user.id
      art.destroy
      Messager.new.publish "/artists/#{artist.id}/art_pieces/delete", "removed art piece #{params[:id]}"
    end
    redirect_to(artist)
  end

  def sidebar_info
  end

  protected
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
