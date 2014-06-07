module Admin
  class StudiosController < BaseAdminController

    layout 'mau-admin'

    before_filter :manager_required
    before_filter :admin_required, :only => [:new, :create, :destroy]
    before_filter :studio_manager_required, :only => [:edit, :update,
                                                      :upload_profile, :add_profile,
                                                      :unaffiliate_artist]
    before_filter :load_studio, :except => [:new, :index, :create]

    def index
      @studios = Studio.all
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
      redirect_to edit_admin_studio_path(@studio), :flash => flash_opts
    end

    def add_profile
      render :layout => 'mau-admin'
    end

    def upload_profile
      if commit_is_cancel
        redirect_to(@studio)
        return
      end

      studio_id = @studio.id
      upload = params[:upload]

      unless upload.present?
        flash[:error] = "You must provide a file."
        redirect_to add_profile_admin_studio_path(@studio) and return
      end

      begin
        StudioImage.new(@studio).save upload
        flash[:notice] = 'Studio Image has been updated.'
        redirect_to @studio and return
      rescue
        logger.error("Failed to upload %s" % $!)
        flash[:error] = "%s" % $!
        redirect_to add_profile_admin_studio_path(@studio) and return
      end
    end


    def studio_manager_required
      unless (is_manager? && current_user.studio.id.to_s == params[:id].to_s) || is_admin?
        redirect_to request.referrer, :flash => {:error => "You are not a manager of that studio."}
      end
    end

    private
    def load_studio
      @studio ||= StudioService.get_studio_from_id(params[:id])
    end

  end
end
