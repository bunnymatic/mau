require 'studio'
class StudiosController < ApplicationController

  layout 'mau1col'
  skip_before_filter :get_feeds, :get_new_art

  before_filter :load_studio_list, :only => [:index, :show]
  before_filter :load_studio, :only => [:edit, :update, :destroy, :show,
                                        :unaffiliate_artist, :upload_profile, :add_profile]

  include OsHelper

  def index
    @view_mode = (params[:v] == 'c') ? 'count' : 'name'

    @studios = StudiosPresenter.new(view_context, @studio_list, @view_mode)

    respond_to do |format|
      format.html { render :layout => 'mau' }
      format.json {
        render :json => @studio_list
      }
      format.mobile {
        @page_title = "Studios"
        render :layout => 'mobile'
      }
    end
  end



  def show
    unless @studio
      flash[:error] = "The studio you are looking for doesn't seem to exist. Please use the links below."
      redirect_to studios_path and return
    end
    @studios = @studio_list.map{|s| StudioPresenter.new(view_context, s, is_mobile?)}
    @studio = StudioPresenter.new(view_context, @studio, is_mobile?)

    @page_title = @studio.page_title

    respond_to do |format|
      format.html { render :layout => 'mau' }
      format.json { render :json => @studio.studio.to_json(:methods => 'artists') }
      format.mobile { render :layout => 'mobile' }
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
