# 5 min exp

class SearchController < ApplicationController
  layout 'mau2col'

  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = "q:"
  @@PER_PAGE = 12

  def index

    # add wildcard
    if !params[:query]
      #TODO handle missing params with error page
      redirect_to('/')
      return
    end
    qq = (params[:query] || "").strip
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
      results = Rails.cache.read(cache_key)
    rescue
      results = nil
    end
    active_artists = Artist.active.all
    active_artist_ids = []
    active_artists.each { |a| active_artist_ids << a.id }
    # If it matches a studio, take them there
    ss = Studio.find(:all, :conditions => ['name = ?', qq])
    if ss and ss.length > 0
      redirect_to( ss[0] )
    end

    # check for artist exact name match
    results = {}
    active_artists.each do |a|
      if /#{qq}/i =~ a.get_name(false)
        if a.representative_piece
          ap = a.representative_piece
          results[ap.id] = ap
        end
      end
    end
      
    qq = "%" + qq.to_s + "%"
    
    if results.empty?
      by_artist = (Artist.active.find(:all, :conditions => ["(firstname like ? or lastname like ? or login like ?) ", qq, qq, qq])).map { |a| a.representative_piece }
    
      tag_ids = (ArtPieceTag.find(:all, :conditions => ["name like ?", qq])).map { |tg| tg.id }
      tags = ArtPiecesTag.find(:all, :conditions => ["art_piece_tag_id in (?)", tag_ids.uniq])
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
      begin 
        [by_art_piece, by_media, by_tags, by_artist].each do |lst|
          if lst.length > 0
            lst.map { |entry| results[entry.id] = entry if entry.id and entry.artist and active_artist_ids.include? entry.artist.id }
          end
        end
      rescue Exception => ex
        logger.warn("Failed to map search results %s" % ex)
      end
      begin
        Rails.cache.write(cache_key, results, :expires_in => @@CACHE_EXPIRY)
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
