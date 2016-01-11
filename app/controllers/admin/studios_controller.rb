module Admin
  class StudiosController < ::BaseAdminController

    before_filter :manager_required
    before_filter :admin_required, only: [:new, :create, :destroy]
    before_filter :studio_manager_required, only: [:edit, :update,
                                                   :unaffiliate_artist]
    before_filter :load_studio, except: [:new, :index, :create, :reorder]
    skip_before_filter :verify_authenticity_token, :only => [:unaffiliate_artist]

    def index
      @studios = StudioService.all.map{|s| StudioPresenter.new(s)}
    end

    def new
      @studio = Studio.new
    end

    def edit
    end

    def create
      @studio = Studio.new(studio_params)

      if @studio.save
        flash[:notice] = 'Studio was successfully created.'
        redirect_to(@studio)
      else
        render 'new'
      end

    end

    def reorder
      studio_slugs = reorder_studio_params
      studios = Studio.where(slug: studio_slugs) + Studio.where(id: studio_slugs)
      studios_lut = studios.inject({}) do |memo, studio|
        memo[studio.slug] = studio
        memo[studio.id.to_s] = studio
        memo
      end
      ActiveRecord::Base.transaction do
        studio_slugs.each_with_index do |slug,idx|
          studios_lut[slug].update_attributes!(position: idx)
        end
      end
      render json: {status: :ok}
    end

    # PUT /studios/1
    def update
      if @studio.update_attributes(studio_params)
        flash[:notice] = 'Studio was successfully updated.'
        redirect_to(@studio) and return
      else
        render "edit"
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
        redirect_to_edit error: 'You cannot unaffiliate yourself' and return
      end
      if StudioArtist.new(@studio,artist).unaffiliate
        msg = {notice: "#{artist.full_name} is no longer associated with #{@studio.name}."}
      else
        msg = {error: "There was a problem finding that artist associated with this studio."}
      end
      redirect_to_edit msg
    end

    def redirect_to_edit(flash_opts)
      redirect_to edit_admin_studio_path(@studio), flash: flash_opts
    end

    def studio_manager_required
      unless (is_manager? && (current_user.studio.to_param == params[:id].to_s)) || is_admin?
        redirect_to request.referrer, flash: {error: "You are not a manager of that studio."}
      end
    end

    private
    def studio_params
      params.require(:studio).permit( :name, :street, :city, :state, :zip, :url, :lat, :lng, :cross_street, :phone, :photo )
    end

    def reorder_studio_params
      params.require(:studios)
    end

    def load_studio
      @studio ||= StudioService.find(params[:id])
    end

  end
end
