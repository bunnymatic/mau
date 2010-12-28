class StudiosController < ApplicationController
  # GET /studios
  # GET /studios.xml
  before_filter :admin_required, :except => [ 'index', 'show' ]
  after_filter :store_location

  @@MIN_ARTISTS_PER_STUDIO = (Conf.min_artists_per_studio or 3)
  layout 'mau1col'

  def admin_index
    @studios = Studio.all
  end

  def index
    studios = Studio.all
    @studios = []
    studios.each do |s| 
      if s.artists.count >= @@MIN_ARTISTS_PER_STUDIO
        @studios << s
      end
    end
    @admin = logged_in? && self.current_user.is_admin?
    render :action => 'index', :layout => 'mau'
  end

  def addprofile
    @errors = []
    @studio = safe_find(params[:id])
    @selected_studio = @studio.id
  end

  def upload_profile
    @studio = safe_find(params[:studio_id])
    if commit_is_cancel
      redirect_to(@studio)
      return
    end

    studio_id = @studio.id
    upload = params[:upload]

    if not upload
      flash[:error] = "You must provide a file."
      redirect_to '/studios/addprofile/%d' % studio_id
      return
    end

    begin
      post = StudioImage.save(upload, @studio)
      redirect_to @studio
      return
    rescue
      logger.error("Failed to upload %s" % $!)
      flash[:error] = "%s" % $!
      redirect_to '/studios/addprofile/%d' % studio_id
      return
    end
  end


  # GET /studios/1
  # GET /studios/1.xml
  def show
    studios = Studio.all
    @studios = []
    studios.each do |s| 
      if s.artists.count > @@MIN_ARTISTS_PER_STUDIO
        @studios << s
      end
    end

    if params[:id] == "0"
      @studio = Studio.indy()
    else
      begin
        @studio = Studio.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        @studio = nil
      end
    end
    if not @studio
      flash[:error] = "The studio you are looking for doesn't seem to exist. Please use the links below."
      redirect_to studios_path
      return
    end
    @selected_studio = @studio.id
    @pieces = []
    @other_artists = []
    @page_title = "Mission Artists United - Studio: %s" % @studio.name
    @studio.artists.each do |a|
      if a.active?
        if a.representative_piece
          @pieces << a.representative_piece
        else
          @other_artists << a
        end
      end
    end
    @other_artists.sort! { |a,b| a.lastname <=> b.lastname }
    @admin = logged_in? && current_user.is_admin?
    logger.debug("StudiosController: found %d pieces to show" % @pieces.length)
    render :action => 'show', :layout => 'mau'
  end

  # GET /studios/new
  # GET /studios/new.xml
  def new
    @studio = Studio.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @studio }
    end
  end

  # GET /studios/1/edit
  def edit
    if self.current_user && self.current_user.is_admin?
      @studio = Studio.find(params[:id])
      @selected_studio = @studio.id
    else
      redirect_to "/error"
    end
  end

  # POST /studios
  # POST /studios.xml
  def create
    @studio = Studio.new(params[:studio])

    respond_to do |format|
      if @studio.save
        flash[:notice] = 'Studio was successfully created.'
        format.html { redirect_to(@studio) }
        format.xml  { render :xml => @studio, :status => :created, :location => @studio }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @studio.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /studios/1
  # PUT /studios/1.xml
  def update
    @studio = Studio.find(params[:id])
    @selected_studio = @studio.id
    respond_to do |format|
      if @studio.update_attributes(params[:studio])
        flash[:notice] = 'Studio was successfully updated.'
        format.html { redirect_to(@studio) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @studio.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /studios/1
  # DELETE /studios/1.xml
  def destroy
    @studio = Studio.find(params[:id])
    @studio.destroy

    respond_to do |format|
      format.html { redirect_to(studios_url) }
      format.xml  { head :ok }
    end
  end

  protected
  def safe_find(id)
    begin
      Studio.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The studio you were looking for was not found."
      return nil
    end
  end

end
