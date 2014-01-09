class MediaController < ApplicationController
  # GET /media
  # GET /media.xml
  layout 'mau1col'
  before_filter :admin_required, :except => [ :index, :show ]
  before_filter :load_media, :only => [:admin_index, :show]
  before_filter :load_media_frequency, :only => [:index, :show]
  after_filter :store_location

  def admin_index
    render :layout => 'mau-admin'
  end

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

  # GET /media/1
  # GET /media/1.xml

  def show
    @medium = Medium.find(params[:id])

    respond_to do |format|
      format.html {
        _show_html
        render :layout => "mau"
      }
      format.mobile {
        @page_title = "Media: " + @medium.name
        _show_mobile
        render :layout => "mobile"
      }
    end
  end

  # GET /media/new
  # GET /media/new.xml
  def new
    @medium = Medium.new
  end

  # GET /media/1/edit
  def edit
    @medium = Medium.find(params[:id])
  end

  def create
    @medium = Medium.new(params[:medium])

    if @medium.save
      Medium.flush_cache
      flash[:notice] = 'Medium was successfully created.'
      redirect_to(@medium)
    else
      render "new"
    end
  end

  def update
    @medium = Medium.find(params[:id])

    if @medium.update_attributes(params[:medium])
      Medium.flush_cache
      flash[:notice] = 'Medium was successfully updated.'
      redirect_to(@medium)
    else
      render :action => "edit"
    end
  end

  def destroy
    @medium = Medium.find(params[:id])
    @medium.destroy

    Medium.flush_cache
    redirect_to(media_url)
  end

  private
  def _show_html
    page = params[:p]
    if not page
      page = 0
    end
    page = page.to_i
    @results_mode = params[:m] || 'p'

    items = @medium.art_pieces.order('created_at')

    # if show by artists, pick 1 from each artist
    if @results_mode == 'p'
      pieces = items.sort_by { |i| i.updated_at }
    else
      tmps = {}
      items.each do |pc|
        if !tmps.include?  pc.artist_id
          tmps[pc.artist_id] = pc
        end
      end
      pieces = tmps.values.sort_by { |p| p.updated_at }
    end
    pieces.reverse!
    @paginator = MediumPagination.new(view_context, pieces, @medium, page, {:m => params[:m]},  4)
    @pieces = @paginator.items

    # still in use
    @by_artists_link = medium_path(@medium, { :m => 'a' })
    @by_pieces_link = medium_path(@medium, { :m => 'p' })

  end

  def _show_mobile
    # find artists using this medium
    items = ArtPiece.where(:medium_id => @medium.id).order('created_at')

    # if show by artists, pick 1 from each artist
    @artists = Artist.find(items.map(&:artist_id).uniq)
  end

  def load_media_frequency
    @frequency = Medium.frequency(true)
  end

  def load_media
    @media ||= Medium.all
  end

end
