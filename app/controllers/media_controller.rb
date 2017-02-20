class MediaController < ApplicationController
  # GET /media
  # GET /media.xml
  before_action :admin_required, :except => [ :index, :show ]
  before_action :load_media, :only => [:show]
  before_action :load_media_frequency, :only => [:index, :show]

  def index
    xtra_params = params.permit(:m)
    if !@frequency.empty?
      freq = @frequency.sort{ |m1,m2| m2['ct'].to_i <=> m1['ct'].to_i }
      med = Medium.find(freq[0]['medium'])
      redirect_to medium_path(med, xtra_params)
      return
    end
    redirect_to medium_path(Medium.first, xtra_params)
  end

  def show
    @medium = Medium.friendly.find(params[:id])
    page = medium_params[:p].to_i
    mode = medium_params[:m]

    @media_presenter = MediaPresenter.new(@medium, page, mode)
    @media_cloud = MediaCloudPresenter.new(Medium, @medium, mode)
    @paginator = @media_presenter.paginator
    # still in use
    @by_artists_link = medium_path(@medium, { :m => 'a' })
    @by_pieces_link = medium_path(@medium, { :m => 'p' })
  end

  private
  def medium_params
    params.permit(:p, :m)
  end

  def load_media_frequency
    @frequency = Medium.frequency(true)
  end

  def load_media
    @media ||= Medium.alpha
  end

end
