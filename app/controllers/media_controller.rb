class MediaController < ApplicationController
  before_action :admin_required, except: %i[index show]
  class NoMediaError < StandardError; end

  def index
    respond_to do |format|
      format.html { redirect_to_most_popular_medium }
    end
  end

  def show
    begin
      @medium = Medium.friendly.includes(art_pieces: { artist: %i[artist_info open_studios_events] }).find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to_most_popular_medium(flash: { error: "Sorry, we couldn't find the medium you were looking for" }) && return
    end

    page = medium_params[:p].to_i

    @media_presenter = MediaPresenter.new(@medium, page)
    @media_cloud = MediaCloudPresenter.new(@medium)
    @paginator = @media_presenter.paginator
  end

  private

  def medium_params
    params.permit(:p)
  end

  def redirect_to_most_popular_medium(redirect_opts = {})
    popular = MediaService.most_popular_medium
    if popular.nil?
      render_not_found NoMediaError.new('No medium matches')
    else
      redirect_to medium_path(popular, medium_params), redirect_opts
    end
  end
end
