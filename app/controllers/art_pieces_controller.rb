class ArtPiecesController < ApplicationController

  include TagsHelper
  layout 'mau1col', :except => :show

  before_filter :admin_required, :only => [ :index, ]
  before_filter :login_required, :only => [ :new, :edit, :update, :create, :destroy]

  after_filter :flush_cache, :only => [:new, :update, :destroy]
  
  def flush_cache
    Medium.flush_cache
    Tag.flush_cache
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
          thumb[:clz] = "tiny-thumb-sel"
          @init_offset = (ctr * -56)
          nxt = [ctr + 1, npieces -1].min
          prv = [ctr - 1, 0].max
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
    
    # get all art pieces for this artist
    pieces = []
    if @art_piece.artist_id > 0
      pieces = ArtPiece.find_all_by_artist_id(@art_piece.artist)
      @page_title = "Mission Artists United - Artist: %s" % @art_piece.artist.get_name
    end
    self._setup_thumb_browser_data(pieces, apid)
    respond_to do |format|
      format.html { render :action => 'show', :layout => 'mau' }
      format.json { render :json => @art_piece.to_json(:include=>[:tags, :medium])  }
    end

  end

  # GET /art_pieces/new
  # GET /art_pieces/new.xml
  def new
    artist = Artist.find(current_artist.id)
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
      if @art_piece.artist != self.current_artist
        flash.now[:error] = 'You can only edit your own works.'
        self._setup_thumb_browser_data([], 0)
        render :action => 'show', :layout => 'mau'
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

  # POST /art_pieces
  # POST /art_pieces.xml
  def create
    if params[:commit].downcase == 'cancel'
      redirect_to(self.current_artist)
      return
    end
    @media = Medium.all

    # if file to upload - upload it first
    @errors = []
    upload = params[:upload]
    saved = false
    if not upload
      flash.now[:error] = "You must provide an image."
      @art_piece = ArtPiece.new
      @art_piece.attributes= params[:art_piece]
      render :action => 'new'
      return
    else 
      params[:art_piece][:tags] = TagsHelper.tags_from_s(params[:tags])
      @art_piece = current_artist.art_pieces.build(params[:art_piece])
      begin
        ActiveRecord::Base.transaction do
          saved = @art_piece.save
          if saved
            # upload image
            if upload
              post = ArtPieceImage.save(upload, @art_piece)
            end
            flash[:notice] = 'Artwork was successfully added.'
          else
            @errors = @art_piece.errors
            @art_piece = ArtPiece.new
            @art_piece.attributes= params[:art_piece]
          end
        end
      rescue 
        @errors << "%s" % $!
        logger.error("Failed to upload %s" % $!)
        @art_piece = ArtPiece.new
        @art_piece.attributes= params[:art_piece]
        render :action => 'new'
        return
      end
    end

    respond_to do |format|
      if saved
        format.html { redirect_to(current_artist) }
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
    if params[:commit].downcase == 'cancel'
      self._setup_thumb_browser_data([], 0)
      render :action => 'show', :layout => 'mau'
      return
    else
      begin
        params[:art_piece][:tags] = TagsHelper.tags_from_s(params[:tags])
        success = @art_piece.update_attributes(params[:art_piece])
      rescue
        logger.warn("Failed to update artpiece : %s" % $!)
        @errors = @art_piece.errors
        @errors.add('Tags','%s' % $!)
        @media = Medium.all
        render :action => "edit"
        return
      end
      if success
        flash.now[:notice] = 'ArtPiece was successfully updated.'
        pieces = ArtPiece.find_all_by_artist_id(@art_piece.artist)
        self._setup_thumb_browser_data(pieces, @art_piece.id)
        render :action => 'show', :layout => 'mau'
      else
        msg = ""
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
    art.destroy

    respond_to do |format|
      format.html { redirect_to(artist) }
      format.xml  { head :ok }
    end
  end

  protected
  def safe_find_art_piece(id)
    begin
      ArtPiece.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The art piece you were looking for was not found."
      return nil
    end
  end

end
