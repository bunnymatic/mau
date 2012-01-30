require 'json'
require 'json/add/core'
require 'json/add/rails' 
class ArtPieceTagsController < ApplicationController
  layout 'mau1col'
  before_filter :admin_required, :except => [ :index, :show ]
  after_filter :store_location

  @@AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['tags']['cache_expiry']
  @@AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['tags']['cache_key']
  
  @@PER_PAGE = 12
  def admin_index
    tags = ArtPieceTag.all
    freq = ArtPieceTag.keyed_frequency
    tags.each do |t|
      if freq.keys.include? t.id
        t['count'] = freq[ t.id ].to_f
      else
        t['count'] = 0
      end
    end
    @tags = tags.sort { |a,b| b['count'] <=> a['count'] } 
    render :layout => "mau-admin"
  end

  def cleanup
    tags = ArtPieceTag.all
    freq = ArtPieceTag.keyed_frequency
    tags.each do |t|
      if freq.keys.include? t.id
        t['count'] = freq[ t.id ].to_f
      else
        t['count'] = 0
      end
    end
    @tags = tags.sort { |a,b| a['count'] <=> b['count'] } 
    @tags.each do |t|
      if t['count'] <= 0
        t.destroy
      end
    end
    redirect_to '/admin/art_piece_tags'
  end    

  def index
    xtra_params = Hash[ params.select{ |k,v| [:m,"m"].include? k } ]
    respond_to do |format|
      format.html { 
        freq = ArtPieceTag.frequency
        if !freq || freq.empty?
          render_not_found Exception.new("No tags in the system")
        else
          params[:id] = freq[0]['tag']
          redirect_to art_piece_tag_path(params[:id], xtra_params)
        end
      }
      format.json  { 
        if params[:suggest]
          tagnames = []
          begin
            cacheout = Rails.cache.read(@@AUTOSUGGEST_CACHE_KEY)
          rescue MemCacheError => mce
            logger.warning("Memcache (read) appears to be dead or unavailable")
            cacheout = nil
          end
          if cacheout
            logger.debug("Fetched autosuggest tags from cache")
            tagnames = ActiveSupport::JSON.decode cacheout
          end
          if !tagnames or tagnames.empty?
            alltags = ArtPieceTag.all
            alltags.each do |t| 
              tagnames << { "value" => t.name, "info" => t.id }
            end
            cachein = ActiveSupport::JSON.encode tagnames
            if cachein
              begin
                Rails.cache.write(@@AUTOSUGGEST_CACHE_KEY, cachein, :expires_in => @@AUTOSUGGEST_CACHE_EXPIRY)
              rescue MemCacheError => mce
                logger.warning("Memcache (write) appears to be dead or unavailable")
              end
            end
          end
          if params[:input]
            # filter with input prefix
            inp = params[:input].downcase
            lin = inp.length - 1
            begin
              tagnames.delete_if {|nm| inp != nm['value'][0..lin].downcase}
            rescue
              tagnames = []
            end
          end
          render :json => tagnames
        else
          tags = ArtPieceTag.all
          render :json => tags 
        end
      }
    end
  end

  # GET /tags/1
  # GET /tags/1.xml
  def show
    # get art pieces by tag
    @freq = ArtPieceTag.frequency(true)
    tags = []
    @freq.each { |t| tags.push(t['tag']) }
    @tags = ArtPieceTag.find_all_by_id(tags)
    @tag = ArtPieceTag.find(params[:id])
    page = 0
    if params[:p]
      page = params[:p].to_i
    end

    @results_mode = params[:m] || 'p'
    artist_ids = Artist.active.all.map{|a| a.id}
    joiner = ArtPiecesTag.find_all_by_art_piece_tag_id(params[:id])
    results = {}
    joiner.each do |apt|
      art = apt.art_piece
      if art
        results[art.id]=art
      end
    end

    # if show by artists, pick 1 from each artist
    if @results_mode == 'p'
      pieces = results.map { |k,v| v }.sort_by { |p| p.updated_at }.reverse
    else
      tmps = {}
      results.values.each do |pc|
        if (pc && !tmps.include?(pc.artist_id) && 
            artist_ids.include?(pc.artist_id))
          tmps[pc.artist_id] = pc
        end
      end
      pieces = tmps.values.sort_by { |p| p.updated_at }.reverse
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

    @by_artists_link = art_piece_tag_url(@tag) + "?m=a"
    @by_pieces_link = art_piece_tag_url(@tag) + "?m=p"
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

    render :action => "show", :layout => "mau"
  end

  def new
    @tag = ArtPieceTag.new
    ArtPieceTag.flush_cache
    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @tag }
    end
  end

  def edit
    @tag = ArtPieceTag.find(params[:id])
  end

  def create
    @tag = ArtPieceTag.new(params[:tag])

    respond_to do |format|
      if @tag.save
        ArtPieceTag.flush_cache
        flash[:notice] = 'ArtPieceTag was successfully created.'
        format.html { redirect_to(@tag) }
        format.xml  { render :xml => @tag, :status => :created, :location => @tag }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @tag = ArtPieceTag.find(params[:id])

    respond_to do |format|
      if @tag.update_attributes(params[:tag])
        ArtPieceTag.flush_cache
        flash[:notice] = 'ArtPieceTag was successfully updated.'
        format.html { redirect_to(@tag) }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @tag.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @tag = ArtPieceTag.find(params[:id])
    @tag.destroy
    ArtPieceTag.flush_cache
    respond_to do |format|
      format.html { redirect_to(art_piece_tags_url) }
      format.xml  { head :ok }
    end
  end

  def autosuggest
  end
end
