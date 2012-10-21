require 'json'
class ArtPiecesController < ApplicationController

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

  @@THUMB_BROWSE_SIZE = 65

  # GET /art_pieces
  # GET /art_pieces.xml
  def index
    @art_pieces = ArtPiece.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @art_pieces }
      format.json  { render :json => @art_pieces }
    end
  end

  def _setup_thumb_browser_data(pieces, cur_id)
    npieces = pieces.length()
    @thumbs = []
    thumb_size = 32
    ctr = 0
    @init_offset = 0
    sz = 56
    if @_ie
      sz = 60
    end
    
    if npieces > 1
      pieces.each do |item| 
        thumb = { :path => item.get_path('thumb') }
        thumb[:clz] = "tiny-thumb" 
        thumb[:id] = item.id
        if item.id == cur_id
          thumb[:clz] = "tiny-thumb tiny-thumb-sel"
          @init_offset = (ctr * -56)
          nxt = [ctr + 1, npieces -1].min
          prv = [ctr - 1, 0].max
          @next_idx = nxt
          @cur_idx = ctr
          @prev_idx = prv
          @next_img = pieces[nxt].id
          @prev_img = pieces[prv].id
        end
        ctr += 1
        thumb[:link] = art_piece_url(item)
        @thumbs << thumb
      end
      @content_width = @thumbs.length * sz
      if @init_offset > -250
        @init_offset = 0
      elsif @init_offset < 500 - @content_width
        @init_offset = 500 - @content_width
      else
        @init_offset += 250
      end
    end
  end

  # GET /art_pieces/1
  # GET /art_pieces/1.xml
  def show
    apid = params[:id].to_i
    @art_piece = safe_find_art_piece(apid)
    # get favorites
    @favorites_count = Favorite.art_pieces.find_all_by_favoritable_id(apid).count
    # get all art pieces for this artist
    pieces = []
    if @art_piece.nil? || !@art_piece.artist_id
      flash[:error] = "We couldn't find that art piece."
      redirect_to "/error"
      return 
    end

    if @art_piece.artist_id > 0
      pieces = ArtPiece.find_all_by_artist_id(@art_piece.artist, :order => '`order` asc, `created_at` desc')
      @page_title = "Mission Artists United - Artist: %s" % @art_piece.artist.get_name
      @page_description = build_page_description @art_piece
      @page_keywords += [@art_piece.art_piece_tags + [@art_piece.medium]].flatten.compact.map(&:name)
    end
    self._setup_thumb_browser_data(pieces, apid)
    @art_piece_dimensions = {
      :large => compute_actual_image_size('original', @art_piece),
      :medium => compute_actual_image_size('medium', @art_piece)
    }
    if (@art_piece_dimensions[:large][0] > @art_piece_dimensions[:medium][0])
      @zoomed_art_piece_path = @art_piece.get_path(:large)
      @zoomed_width = @art_piece_dimensions[:large][0]
      @zoomed_height = @art_piece_dimensions[:large][1]
    end
    
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'mau' }
      format.json { 
        h={}
        h['art_piece'] = @art_piece.attributes
        # make safe the art_piece entries
        h['art_piece']["art_piece_tags"] = []
        @art_piece.art_piece_tags.each { |t|
          h['art_piece']['art_piece_tags'] << t.attributes
        }
        m = @art_piece.medium
        if m
          h['art_piece']["medium"] = @art_piece.medium.attributes
        end
        [ 'title','dimensions'].each do |k| 
          h['art_piece'][k] = HTMLHelper.encode(h['art_piece'][k])
        end
        h['art_piece']['art_piece_tags'].each do |t| 
          t['name'] = HTMLHelper.encode(t['name'])
        end

        if (current_user && current_user.id == @art_piece.artist.id)
          h['art_piece']['buttons'] = render_to_string :partial => "edit_delete_buttons"
        end
        h['art_piece'].merge!(:favorites_count => @favorites_count)
        render :json => h.to_json
      }
    end

  end

  # GET /art_pieces/new
  # GET /art_pieces/new.xml
  def new
    artist = Artist.find(current_user.id)
    cur_pieces = artist.art_pieces.length
    if cur_pieces >= artist.max_pieces
      flash.now[:error] = "You cannot have more than %s art pieces.  If you decide to continue adding art, the oldest pieces will be removed to make space for the new ones.  Alternatively, you could go delete specific pieces to make room for the new ones." % artist.max_pieces
    end
    @art_piece = ArtPiece.new
    @media = Medium.all
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @art_piece }
    end
  end

  # GET /art_pieces/1/edit
  def edit
    begin
      @art_piece = safe_find_art_piece(params[:id])
      if @art_piece.artist != current_user
        flash[:error] = "You're not allowed to edit that work."
        redirect_to "/error"
      end
      @media = Medium.all
      if @art_piece.medium
        @selected_medium = @art_piece.medium
      else
        @selected_medium = []
      end
    rescue ActiveRecord::RecordNotFound
      @art_piece = nil
      @selected_medium = nil
    end
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
    if not upload
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
            @errors = @art_piece.errors
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

    respond_to do |format|
      if saved
        format.html { redirect_to(current_user) }
        format.xml  { render :xml => @art_piece, :status => :created, :location => @art_piece }
      else
        @media = Medium.all
        format.html { render :action => "new" }
        format.xml  { render :xml => @art_piece.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /art_pieces/1
  # PUT /art_pieces/1.xml
  def update
    @art_piece = safe_find_art_piece(params[:id])
    if commit_is_cancel
      self._setup_thumb_browser_data([], 0)
      render :action => 'show', :layout => 'mau'
      return
    else
      begin
        params[:art_piece][:art_piece_tags] = TagsHelper.tags_from_s(params[:tags])
        success = @art_piece.update_attributes(params[:art_piece])
      rescue
        logger.warn("Failed to update artpiece : %s" % $!)
        @errors = @art_piece.errors
        @errors.add('ArtPieceTags','%s' % $!)
        @media = Medium.all
        render :action => "edit"
        return
      end
      if success
        flash[:notice] = 'Artwork was successfully updated.'
        Messager.new.publish "/artists/#{current_user.id}/art_pieces/update", "updated art piece #{@art_piece.id}"
        redirect_to art_piece_path(@art_piece)
      else
        @errors = @art_piece.errors
        @art_piece = safe_find_art_piece(params[:id])
        @media = Medium.all
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
    art = safe_find_art_piece(params[:id])
    artist = art.artist
    if artist.id == current_user.id
      art.destroy
      Messager.new.publish "/artists/#{artist.id}/art_pieces/delete", "removed art piece #{params[:id]}"
    end
    respond_to do |format|
      format.html { redirect_to(artist) }
      format.xml  { head :ok }
    end
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
