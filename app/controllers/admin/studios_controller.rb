# frozen_string_literal: true
module Admin
  class StudiosController < ::BaseAdminController
    before_action :manager_required
    before_action :admin_required, only: [:new, :create, :destroy]
    before_action :studio_manager_required, only: [:edit, :update,
                                                   :unaffiliate_artist]
    before_action :load_studio, except: [:new, :index, :create, :reorder]
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
          studios_lut[slug].update_attributes!(position: idx)
        end
      end
      render json: { status: :ok }
    end

    # PUT /studios/1
    def update
      if @studio.update_attributes(studio_params)
        flash[:notice] = "That's great that we're keeping studio data current.  Keep up the good work."
        redirect_to(@studio) and return
      else
        render 'edit'
      end
    end

    def destroy
      if @studio
        @studio.artists.each do |artist|
          artist.update_attribute(:studio_id, 0)
        end
        @studio.destroy
      end

      redirect_to(studios_url, notice: 'Sad to see them go.  But there are probably more right around the bend.')
    end

    def unaffiliate_artist
      artist = Artist.find(params[:artist_id])
      if artist == current_artist
        redirect_to_edit error: 'You cannot unaffiliate yourself' and return
      end
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
      unless (is_manager? && (current_user.studio.to_param == params[:id].to_s)) || is_admin?
        redirect_to request.referer, flash: { error: 'You are not a manager of that studio.' }
      end
    end

    private

    def studio_params
      params.require(:studio).permit(:name, :street, :city, :state, :zip,
                                     :url, :lat, :lng, :cross_street, :phone, :photo)
    end

    def reorder_studio_params
      params.require(:studios)
    end

    def load_studio
      @studio ||= StudioService.find(params[:id])
    end
  end
end
