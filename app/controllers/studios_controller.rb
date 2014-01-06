require 'studio'
class StudiosController < ApplicationController

  before_filter :manager_required, :except => [ :index, :show, :new ]
  before_filter :admin_required, :only => [:new, :create, :destroy]
  before_filter :studio_manager_required, :only => [:edit, :update, :upload_profile, :add_profile, :unaffiliate_artist]
  after_filter :store_location

  before_filter :load_studio, :only => [:edit, :update, :destroy, :show, 
                                        :unaffiliate_artist, :upload_profile, :add_profile]
  MIN_ARTISTS_PER_STUDIO = (Conf.min_artists_per_studio or 3)
  layout 'mau1col'

  include OsHelper
  def admin_index
    @studios = Studio.all
    render :layout => 'mau-admin'
  end

  def index
    @view_mode = (params[:v] == 'c') ? 'count' : 'name'

    studios = get_studio_list
    @studios = StudiosPresenter.new(studios, @view_mode)

    respond_to do |format|
      format.html { render :layout => 'mau' }
      format.json {
        render :json => studios
      }
      format.mobile {
        @page_title = "Studios"
        @studios = studios.reject{|s| s.active_artists.length < 1}
        render :layout => 'mobile'
      }
    end
  end

  def unaffiliate_artist
    artist = Artist.find(params[:artist_id])
    if artist == current_artist
      redirect_to_edit :error => 'You cannot unaffiliate yourself' and return
    end
    if StudioArtist.new(@studio,artist).unaffiliate
      msg = {:notice => "#{artist.fullname} is no longer associated with #{@studio.name}."}
    else
      msg = {:error => "There was a problem finding that artist associated with this studio."}
    end
    redirect_to_edit msg
  end

  def redirect_to_edit(flash_opts)
    redirect_to edit_studio_path(@studio), :flash => flash_opts
  end

  def add_profile
    @errors = []
    @selected_studio = @studio.id
    render :layout => 'mau-admin'
  end

  def upload_profile
    if commit_is_cancel
      redirect_to(@studio)
      return
    end

    studio_id = @studio.id
    upload = params[:upload]

    if not upload
      flash[:error] = "You must provide a file."
      redirect_to add_profile_studio_path(@studio) and return
    end

    begin
      post = StudioImage.new(upload, @studio).save
      redirect_to @studio and return
    rescue
      logger.error("Failed to upload %s" % $!)
      flash[:error] = "%s" % $!
      redirect_to add_profile_studio_path(@studio) and return
    end
  end


  def show
    @studios = get_studio_list

    unless @studio
      flash[:error] = "The studio you are looking for doesn't seem to exist. Please use the links below."
      redirect_to studios_path
      return
    end

    @studio = StudioPresenter.new(view_context, @studio, is_mobile?)
    @page_title = @studio.page_title

    respond_to do |format|
      format.html { render :layout => 'mau' }
      format.json { render :json => @studio.studio.to_json(:methods => 'artists') }
      format.mobile { render :layout => 'mobile' }
    end
  end

  def new
    @studio = Studio.new
    render :layout => 'mau-admin'
  end

  def edit
    render :layout => 'mau-admin'
  end

  def create
    @studio = Studio.new(params[:studio])

    if @studio.save
      flash[:notice] = 'Studio was successfully created.'
      redirect_to(@studio)
    else
      render 'new', :layout => 'mau-admin'
    end

  end

  # PUT /studios/1
  def update
    @selected_studio = @studio.id
    if @studio.update_attributes(params[:studio])
      flash[:notice] = 'Studio was successfully updated.'
      redirect_to(@studio)
    else
      render "edit", :layout => 'mau-admin'
    end
  end

  def destroy
    if @studio
      @studio.artists.each do |artist|
        artist.update_attribute(:studio_id, 0)
      end
      @studio.destroy
    end

    redirect_to(studios_url)
  end

  protected
  def studio_manager_required
    unless (is_manager? && current_user.studio.id.to_s == params[:id].to_s) || is_admin?
      redirect_to request.referrer, :flash => {:error => "You are not a manager of that studio."}
    end
  end

  def safe_find(id)
    begin
      Studio.find(id)
    rescue ActiveRecord::RecordNotFound
      flash.now[:error] = "The studio you were looking for was not found."
      return nil
    end
  end

  def get_studio_list
    Studio.all.select do |s|
      if s.id != 0 && s.name == 'Independent Studios'
        false
      else
        s.artists.active.count >= MIN_ARTISTS_PER_STUDIO
      end
    end
  end

  def load_studio
    @studio ||= get_studio_from_id(params[:id])
  end

  def get_studio_from_id(_id)

    def studio_keys
      @studio_keys ||= Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s]}].freeze
    end

    if (_id == 'independent_studios') || (_id.to_s == '0')
      studio = Studio.indy()
    else
      studio = studio_keys[_id]
    end
    if studio
      studio
    else
      begin
        Studio.find _id
      rescue ActiveRecord::RecordNotFound
      end
    end
  end
end
