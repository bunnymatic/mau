class MediaController < ApplicationController
  # GET /media
  # GET /media.xml
  layout 'mau1col'
  before_filter :admin_required, :except => [ 'index', 'show' ]

  @@PER_PAGE = 12
  def admin_index
    @media = Medium.all
  end

  def index
    xtra_params = Hash[ params.select{ |k,v| [:m].include? k } ]
    @Freq = Medium.frequency(true)
    if !@freq.empty?
      freq = @freq.sort{ |m1,m2| m2['ct'].to_i <=> m1['ct'].to_i }
      med = Medium.find(freq[0]['medium'])
      logger.info("Redirect to #{med} #{xtra_params}")
      redirect_to medium_path(med, xtra_params)
      return
    end
    redirect_to medium_path(Medium.first, xtra_params)
  end

  # GET /media/1
  # GET /media/1.xml
  def show
    @freq = Medium.frequency(true)
    @media = Medium.all
    begin
      @medium = Medium.find(params[:id])
    rescue
      if Medium.first.id == 0
        render '/error', "Media haven't been properly setup."
        return
      else
        redirect_to medium_path(Medium.first)
        return
      end
    end
    page = params[:p]
    if not page
      page = 0
    end
    page = page.to_i
    @results_mode = params[:m] || 'p'

    items = ArtPiece.find_all_by_medium_id(@medium.id, :order => 'created_at')
    
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
    @pieces, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(pieces, page, @@PER_PAGE)
    if curpage > lastpage
      curpage = lastpage
    elsif curpage < 0
      curpage = 0
    end
    show_next = (curpage != lastpage)
    show_prev = (curpage > 0)

    @by_artists_link = medium_path(@medium, { :m => 'a' })
    @by_pieces_link = medium_path(@medium, { :m => 'p' })
    if @results_mode == 'p'
      base_link = @by_pieces_link + "&"
    else
      base_link = @by_artists_link + "&"
    end
    arg = "p=%d"
    nxtmod = arg % nextpage
    prvmod = arg % prevpage
    lastmod = arg % lastpage
    
    if show_next
      @next_link = base_link + nxtmod
      @last_link = base_link + lastmod
    end
    if show_prev
      @prev_link = base_link + prvmod
      @first_link = base_link
    end
    # display page and last should be indexed staring with 1 not 0
    @last = lastpage + 1
    @page = curpage + 1

    match = @medium
    if @freq
      @freq.each do |t|
        mid = t["medium"]
        ct = t["ct"]
        (sz, mrg) = TagsHelper.fontsize_from_frequency(ct)
        medium = @media.select do |m|
          m.id.to_i == mid.to_i
        end.first
        if medium == match
          matchclass = "tagmatch"
        else
          matchclass = ""
        end
      end
    end
    render :layout => "mau"
  end

  # GET /media/new
  # GET /media/new.xml
  def new
    @medium = Medium.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @medium }
    end
  end

  # GET /media/1/edit
  def edit
    @medium = Medium.find(params[:id])
  end

  # POST /media
  # POST /media.xml
  def create
    @medium = Medium.new(params[:medium])

    respond_to do |format|
      if @medium.save
        Medium.flush_cache
        flash[:notice] = 'Medium was successfully created.'
        format.html { redirect_to(@medium) }
        format.xml  { render :xml => @medium, :status => :created, :location => @medium }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @medium.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /media/1
  # PUT /media/1.xml
  def update
    @medium = Medium.find(params[:id])

    respond_to do |format|
      if @medium.update_attributes(params[:medium])
        Medium.flush_cache
        flash[:notice] = 'Medium was successfully updated.'
        format.html { redirect_to(@medium) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @medium.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /media/1
  # DELETE /media/1.xml
  def destroy
    @medium = Medium.find(params[:id])
    @medium.destroy

    Medium.flush_cache
    respond_to do |format|
      format.html { redirect_to(media_url) }
      format.xml  { head :ok }
    end
  end
end
