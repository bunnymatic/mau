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

    respond_to do |format|
      format.html {
        _show_html
      }
      format.mobile {
        @page_title = "Media: " + @medium.name
        _show_mobile
        render :layout => "mobile"
      }
    end
  end

  private
  def _show_html
    @media_presenter = MediaPresenter.new(view_context, @medium, params[:p], params[:m])
    @pieces = @media_presenter.art_pieces
    @paginator = @media_presenter.paginator
    # still in use
    @by_artists_link = medium_path(@medium, { :m => 'a' })
    @by_pieces_link = medium_path(@medium, { :m => 'p' })
  end

  def _show_mobile
    # find artists using this medium
    items = ArtPiece.where(:medium_id => @medium.id).order('created_at')

    # if show by artists, pick 1 from each artist
    @artists = Artist.active.includes(:artist_info).where(:id => items.map(&:artist_id).uniq)
  end

  def load_media_frequency
    @frequency = Medium.frequency(true)
  end

  def load_media
    @media ||= Medium.alpha
  end

end
