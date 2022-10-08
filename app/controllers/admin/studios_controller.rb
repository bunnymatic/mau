module Admin
  class StudiosController < ::BaseAdminController
    before_action :manager_required
    before_action :admin_required, only: %i[new create destroy]
    before_action :studio_manager_required,
                  only: %i[
                    edit
                    update
                    unaffiliate_artist
                  ]
    before_action :load_studio, except: %i[new index create reorder]
    skip_before_action :verify_authenticity_token, only: [:unaffiliate_artist]

    def index
      @studios = StudioService.all.map { |s| StudioPresenter.new(s) }
    end

    def new
      @studio = Studio.new
    end

    def edit; end

    def create
      @studio = Studio.new(studio_params)
      @file = studio_params.delete(:photo)
      @studio.photo.attach(@file) if @file
      if @studio.save
        flash[:notice] = 'Awesome!  More studios means more artists!'
        redirect_to(@studio)
      else
        render 'new'
      end
    end

    def reorder
      studio_slugs = reorder_studio_params
      studios = Studio.where(slug: studio_slugs) + Studio.where(id: studio_slugs)
      studios_lut = studios.each_with_object({}) do |studio, memo|
        memo[studio.slug] = studio
        memo[studio.id.to_s] = studio
      end
      ActiveRecord::Base.transaction do
        studio_slugs.each_with_index do |slug, idx|
          studios_lut[slug].update!(position: idx)
        end
      end
      render json: { status: :ok }
    end

    # PUT /studios/1
    def update
      if @studio.update(studio_params)
        flash[:notice] = "It's so great that we're keeping studio data current.  Keep up the good work."
        redirect_to(@studio) && return
      else
        render 'edit'
      end
    end

    def destroy
      @studio&.destroy

      redirect_to(studios_url, notice: 'Sad to see them go.  But there are probably more right around the bend.')
    end

    def unaffiliate_artist
      artist = Artist.find(params[:artist_id])
      redirect_to_edit(error: 'You cannot unaffiliate yourself') && return if artist == current_artist

      msg = if StudioArtist.new(@studio, artist).unaffiliate
              { notice: "#{artist.full_name} is no longer associated with #{@studio.name}." }
            else
              { error: 'There was a problem finding that artist associated with this studio.' }
            end
      redirect_to_edit msg
    end

    def redirect_to_edit(flash_opts)
      redirect_to edit_admin_studio_path(@studio), flash: flash_opts
    end

    def studio_manager_required
      return if (manager? && (current_user.studio.to_param == params[:id].to_s)) || admin?

      redirect_to request.referer, flash: { error: 'You are not a manager of that studio.' }
    end

    private

    def studio_params
      params.require(:studio).permit(:name,
                                     :street,
                                     :city,
                                     :state,
                                     :zipcode,
                                     :url,
                                     :lat,
                                     :lng,
                                     :cross_street,
                                     :phone,
                                     :photo)
    end

    def reorder_studio_params
      params.require(:studios)
    end

    def load_studio
      @studio ||= StudioService.find(params[:id])
    end
  end
end
