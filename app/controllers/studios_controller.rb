# frozen_string_literal: true

require 'studio'
class StudiosController < ApplicationController
  before_action :load_studio_list, only: %i[index show]
  before_action :load_studio, only: %i[show]

  def index
    respond_to do |format|
      format.html do
        @studios = StudiosPresenter.new(@studio_list)
      end
      format.json do
        head(403)
      end
    end
  end

  def show
    unless @studio
      flash[:error] = "The studio you are looking for doesn't seem to exist. Please use the links below."
      redirect_to(studios_path) && return
    end

    respond_to do |format|
      format.html do
        @studio = StudioPresenter.new(@studio)
        @page_title = @studio.page_title
      end
      format.json do
        head(403)
      end
    end
  end

  protected

  def load_studio_list
    @studio_list = StudioService.all_studios
  end

  def load_studio
    @studio ||= StudioService.find(params[:id])
  end
end
