# 5 min exp
require 'pp'

def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

class SearchController < ApplicationController
  layout 'mau'

  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = "q:"
  @@PER_PAGE = 12

  def index

    # add wildcard
    params.symbolize_keys!
    if !params[:keywords]
      #TODO handle missing params with error page
      redirect_to('/')
      return
    end
    @keywords = params[:keywords].split(",").map(&:strip)
    lc_keywords = @keywords.map(&:downcase)

    medium_ids = (params[:medium] || []).compact.map(&:to_i).reject{|v| v <= 0}
    @mediums = Medium.find_all_by_id(medium_ids)
    studio_ids = (params[:studio] || []).compact.map(&:to_i).reject{|v| v <= 0}
    @studios = Studio.find_all_by_id(studio_ids)
    @open_studios_flag = { '1' => true, '2' => false }[params[:os_artist]]
        
    qq = @keywords.compact.join(" ")
    page = 0
    if params[:p]
      page = params[:p].to_i
    end
    @results_mode = params[:m]
    @user_query = qq
    @cur_link = "?keywords=%s" % qq
    @page_title = "Mission Artists United - Search Results - %s" % qq
    qq.downcase!
    results = {}

    if !@keywords.empty?

      active_artists = Artist.active.all

      results_by_kw = {}
      lc_keywords.each do |kw|
       
        kw_query_param = "%#{kw}%"
        partial_results = ArtPiece.find(:all, :conditions => ["title like ?", kw_query_param]) 
        partial_results += ((Artist.active.find(:all, :conditions => ["(firstname like ? or lastname like ?) ", kw_query_param, kw_query_param ])).map{ |a| a.art_pieces }.flatten - partial_results)
        tag_ids = ArtPieceTag.find_all_by_name(kw)
        tags = ArtPiecesTag.find(:all, :conditions => ["art_piece_tag_id in (?)", tag_ids])

        partial_results += ArtPiece.find_all_by_id( tags.map(&:art_piece_id) )

        partial_results += active_artists.select{|a| a.fullname.downcase == kw}.map(&:art_pieces).flatten

        results_by_kw[kw] = partial_results.uniq_by{|obj| obj.id}
      end

      partial_results = results_by_kw.values.compact.flatten
      hits = histogram partial_results.map(&:id)
      num_keywords = @keywords.size
      partial_results.reject!{|ap| hits[ap.id] < num_keywords}

      # filter by mediums and or studios
      if (medium_ids && !medium_ids.empty?)
        partial_results.reject!{|ap| !ap.medium_id || !medium_ids.include?(ap.medium_id) }
      end
      if (studio_ids && !studio_ids.empty?)
        partial_results.reject!{|ap| !ap.artist || !ap.artist.studio || !studio_ids.include?(ap.artist.studio.id)}
      end
      unless @open_studios_flag.nil?
        if @open_studios_flag
          partial_results.reject!{|ap| !ap.artist.doing_open_studios?}
        else
          partial_results.reject!{|ap| ap.artist.doing_open_studios?}
        end
      end
      
      results = {}
      begin 
        active_artist_ids = active_artists.map(&:id)
        partial_results.flatten.compact.flatten.each do |entry|
          results[entry.id] = entry if entry.id and entry.artist && entry.artist.active?
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
    
    results = results.values.sort_by { |p| p.updated_at }
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
