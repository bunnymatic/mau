class TagsController < ApplicationController
  # GET /tags
  # GET /tags.xml
  layout 'mau1col'
  before_filter :admin_required, :except => [ 'index', 'show' ]

  @@NUM_SHOW_TAGS = 50
  @@PER_PAGE = 12
  def admin_index
    @tags = Tag.all
    freq = Tag.keyed_frequency
    @tags.each do |t|
      if freq.keys.include? t.id.to_s
        t['count'] = freq[ t.id.to_s ].to_i
      else
        t['count'] = 0
      end
    end
  end

  def index
    @freq = Tag.frequency
    redirect_to "/tags/%d" % @freq[0]['tag']
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    # get art pieces by tag
    @freq = Tag.frequency
    @tags = Tag.all
    # limit # tags to top NUM_SHOW_TAGS
    @freq.sort! { |t1,t2| t1['tag'] <=> t2['tag'] }
    @tags = @tags[0..@@NUM_SHOW_TAGS]
    @tag = Tag.find(params[:id])
    page = 0
    if params[:p]
      page = params[:p].to_i
    end

    @results_mode = params[:m]
    artist_ids = Artist.all.map{|a| a.id}
    joiner = ArtPiecesTag.find_all_by_tag_id(params[:id])
    results = {}
    joiner.map { |ap| results[ap.art_piece_id] = ap.art_piece }

    # if show by artists, pick 1 from each artist
    if @results_mode == 'p'
      pieces = (joiner.map { |ap| ap.art_piece }).sort_by { |p| p.updated_at }
    else
      tmps = {}
      results.values.each do |pc|
        if (pc && !tmps.include?(pc.artist_id) && 
            artist_ids.include?(pc.artist_id))
          tmps[pc.artist_id] = pc
        end
      end
      pieces = tmps.values.sort_by { |p| p.updated_at }
    end

    @pieces, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(pieces, page, @@PER_PAGE)
    if curpage > lastpage
      curpage = lastpage
    elsif curpage < 0
      curpage = 0
    end
    show_next = (curpage != lastpage)
    show_prev = (curpage > 0)

    @by_artists_link = tag_url(@tag)
    @by_pieces_link = tag_url(@tag) + "?m=p"
    if @results_mode == 'p'
      base_link = @by_pieces_link + "&"
    else
      base_link = @by_artists_link + "?"
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

    render :action => "show", :layout => "mau"
  end

  # GET /tags/new
  # GET /tags/new.xml
  def new
    @tag = Tag.new

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  # GET /tags/1/edit
  def edit
    @tag = Tag.find(params[:id])
  end

  # POST /tags
  # POST /tags.xml
  def create
    @tag = Tag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        flash[:notice] = 'Tag was successfully created.'
        format.html { redirect_to(@tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /tags/1
  # PUT /tags/1.xml
  def update
    @tag = Tag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        flash[:notice] = 'Tag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /tags/1
  # DELETE /tags/1.xml
  def destroy
    @tag = Tag.find(params[:id])
    @tag.destroy

    respond_to do |format|
      format.html { redirect_to(tags_url) }
      format.xml  { head :ok }
    end
  end

end
