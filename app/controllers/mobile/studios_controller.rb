class Mobile::StudiosController < ApplicationController
  layout 'mobile'

  def index
    @studios = Studio.all
  end

  def show
    if params[:id].blank?
      redirect_to mobile_studios_path
    end
    @studio = Studio.find(params[:id])
  end
end
