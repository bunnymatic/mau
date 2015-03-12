class MediaController < ApplicationController
  # GET /media
  # GET /media.xml
  skip_before_filter :get_new_art, :get_feeds

  before_filter :admin_required, :except => [ :index, :show ]
  before_filter :load_media, :only => [:show]
  before_filter :load_media_frequency, :only => [:index, :show]

  def index
    xtra_params = Hash[ params.select{ |k,v| [:m, "m"].include? k } ]
    if !@frequency.empty?
      freq = @frequency.sort{ |m1,m2| m2['ct'].to_i <=> m1['ct'].to_i }
      begin
        med = Medium.find(freq[0]['medium'])
        redirect_to medium_path(med, xtra_params)
        return
      rescue
      end
    end
    redirect_to medium_path(Medium.first, xtra_params)
  end

  def show
    @medium = Medium.find(params[:id])

    page = params[:p].to_i
    mode = params[:m] 

    @media_presenter = MediaPresenter.new(@medium, page, mode)
    @media_cloud = MediaCloudPresenter.new(Medium, @medium, mode)
    @paginator = @media_presenter.paginator
    # still in use
    @by_artists_link = medium_path(@medium, { :m => 'a' })
    @by_pieces_link = medium_path(@medium, { :m => 'p' })
  end

  private
  def load_media_frequency
    @frequency = Medium.frequency(true)
  end

  def load_media
    @media ||= Medium.alpha
  end

end
