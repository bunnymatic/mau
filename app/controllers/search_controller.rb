# 5 min exp

class SearchController < ApplicationController
  layout 'mau2col'
  before_filter :load_studios
  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = (Conf.cache_ns or '') + "q:"
  @@PER_PAGE = 12

  def index
    # add wildcard
    if !params[:query]
      #TODO handle missing params with error page
      redirect_to('/')
      return
    end

    qq = params[:query]
    page = 0
    if params[:p]
      page = params[:p].to_i
    end
    @results_mode = params[:m]
    @user_query = qq
    @cur_link = "?query=%s" % qq
    @page_title = "Mission Artists United - Search Results - %s" % qq
    results = nil
    qq.downcase!
    cache_key = "%s:%s:%s:%s" % [@@QUERY_KEY_PREFIX, qq, page, @results_mode]
    cache_key.gsub!(' ','')
    begin
      results = CACHE.get(cache_key)
    rescue
      results = nil
    end
    active_artists = Artist.find(:all, :conditions => ["state='active'"])
    active_artist_ids = []
    active_artists.each { |a| active_artist_ids << a.id }
    # If it matches a studio, take them there
    ss = Studio.find(:all, :conditions => ['name = ?', qq])
    if ss and ss.length > 0
      redirect_to( ss[0] )
    end

    # check for artist exact name match
    active_artists.each do |a|
      if a.get_name(false) == qq
        ap = a.representative_piece
        results = { ap.id => ap }
      end
    end
      
    qq = "%" + qq + "%"
    
    if not results
      qs = qq.split(/\s+/)
      name_clause = ''
      
      by_artist = (Artist.find(:all, :conditions => ["(firstname like ? or lastname like ? or login like ?) and state = 'active'", qq, qq, qq])).map { |a| a.representative_piece }
    
      tag_ids = (Tag.find(:all, :conditions => ["name like ?", qq])).map { |tg| tg.id }
      tags = ArtPiecesTag.find(:all, :conditions => ["tag_id in (?)", tag_ids.uniq])
      ap_ids = tags.map { |tg| tg.art_piece_id }
      begin
        by_tags = ArtPiece.find(ap_ids)
      rescue
        logger.warn("Failed to find art piece ids %s" % ap_ids)
        by_tags = []
      end

      media_ids = (Medium.find(:all, :conditions=>["name like ?", qq])).map { |i| i.id }.uniq
      by_media = ArtPiece.find_all_by_medium_id(media_ids)

      by_art_piece = ArtPiece.find(:all, :conditions => ["filename like ? or title like ? or medium_id in (?)", qq, qq, media_ids ]) 

      # join all uniquely and sort by recently added
      results = {}
      p active_artist_ids
      begin
        [by_art_piece, by_media, by_tags, by_artist].each do |lst|
          lst.map { |entry| results[entry.id] = entry if entry.id and active_artist_ids.include? entry.artist.id }
        end
      rescue
        logger.warn("Failed to map search results")
      end
      results.values.each { |r| p "RESULT ", r }
      begin
        CACHE.set(cache_key, results, @@CACHE_EXPIRY)      
        logger.debug("Search Results: fetched results from cache")
      rescue
        logger.warn("Search Results: failed to set cache")
      end
    end

    tmps = {}
    results.values.each do |pc|
      if pc
        if !tmps.include?  pc.artist_id
          tmps[pc.artist_id] = pc
        end
      end
    end
    results = tmps.values.sort_by { |p| p.updated_at }
    @pieces, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(results, page, @@PER_PAGE)
    if curpage > lastpage
      curpage = lastpage
    elsif curpage < 0
      curpage = 0
    end
    show_next = (curpage != lastpage)
    show_prev = (curpage > 0)

    if show_next
      @next_link = @cur_link + ("&p=%d" % nextpage)
    end
    if show_prev
      @prev_link = @cur_link += ("&p=%d" % prevpage)
    end
    @last = lastpage + 1
    @page = curpage + 1
  end
end
