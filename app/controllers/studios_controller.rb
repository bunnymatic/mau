require 'studio'
class StudiosController < ApplicationController

  before_filter :load_studio_list, only: [:index, :show]
  before_filter :load_studio, only: [:edit, :update, :destroy, :show,
                                        :unaffiliate_artist, :upload_profile, :add_profile]

  def index
    respond_to do |format|
      format.html {
        @studios = StudiosPresenter.new(@studio_list)
      }
      format.json {
        render json: @studio_list
      }
    end
  end

  def show
    unless @studio
      flash[:error] = "The studio you are looking for doesn't seem to exist. Please use the links below."
      redirect_to studios_path and return
    end
    
    respond_to do |format|
      format.html {
        @studio = StudioPresenter.new(@studio)
        @page_title = @studio.page_title
      }
      format.json {
        render json: StudioSerializer.new(@studio)
      }
    end
  end

  protected

  def load_studio_list
    @studio_list = StudioService.all_studios.sort(&Studio::SORT_BY_NAME)
  end

  def load_studio
    @studio ||= StudioService.get_studio_from_id(params[:id])
  end

end
