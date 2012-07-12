class StudiosController < ApplicationController

  STUDIO_KEYS = Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s.name]}].freeze
  
  before_filter :admin_required, :except => [ 'index', 'show' ]
  after_filter :store_location

  @@MIN_ARTISTS_PER_STUDIO = (Conf.min_artists_per_studio or 3)
  layout 'mau1col'

  def admin_index
    @studios = Studio.all
    render :layout => 'mau-admin'
  end

  def index
      
    @view_mode = (params[:v] == 'c') ? 'count' : 'name'
    @studios = get_studio_list
    @admin = logged_in? && self.current_user.is_admin?
    @studios_by_count = nil
    @studios_by_count = @studios.sort{|a,b| b.artists.active.count <=> a.artists.active.count} if @view_mode == 'count'
    respond_to do |format|
      format.html { render :layout => 'mau' }
      format.json {
        render :json => @studios
      }
      format.mobile { 
        @page_title = "Studios"
        @studios.reject!{|s| s.artists.active.count < 1}
        render :layout => 'mobile' 
      }
    end
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
    @studios = get_studio_list
    if params[:id] == 'independent_studios'
      @studio = Studio.indy()
    elsif STUDIO_KEYS.keys.include? params[:id]
      @studio = Studio.find_by_name(STUDIO_KEYS[params[:id]])
    end
    unless @studio
      if params[:id] == "0"
        @studio = Studio.indy()
      else
        begin
          @studio = Studio.find(params[:id])
        rescue ActiveRecord::RecordNotFound
          @studio = nil
        end
      end
    end

    unless @studio
      flash[:error] = "The studio you are looking for doesn't seem to exist. Please use the links below."
      redirect_to studios_path
      return
    end
    @selected_studio = @studio.id
    @artists = []
    @other_artists = []
    @page_title = "Mission Artists United - Studio: %s" % @studio.name
    unless @_ismobile
      @artists, @other_artists = @studio.artists.active.partition{|a| a.representative_piece}
    else
      @page_title = "Studio: " + @studio.name
    end

    @other_artists.sort! { |a,b| a.lastname <=> b.lastname }
    @admin = logged_in? && current_user.is_admin?
    logger.debug("StudiosController: found %d artists to show" % @artists.length)
    respond_to do |format|
      format.html { render :layout => 'mau' }
      format.json { render :json => @studio.to_json(:methods => 'artists') }
      format.mobile { render :layout => 'mobile' }
    end
  end

  # GET /studios/new
  # GET /studios/new.xml
  def new
    @studio = Studio.new

    respond_to do |format|
      format.html { render :layout => 'mau-admin' }# new.html.erb
      format.xml  { render :xml => @studio }
    end
  end

  # GET /studios/1/edit
  def edit
    if self.current_user && self.current_user.is_admin?
      @studio = Studio.find(params[:id])
      @selected_studio = @studio.id
      render :layout => 'mau-admin'
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
    if @studio
      @studio.artists.each do |artist|
        artist.update_attribute(:studio_id, 0)
      end
      @studio.destroy
    end

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

  def get_studio_list
    Studio.all.select{|s| s.artists.active.count >= @@MIN_ARTISTS_PER_STUDIO }
  end
end
