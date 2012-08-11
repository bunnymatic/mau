# 5 min exp
require 'pp'

def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

class SearchController < ApplicationController
  layout 'mau'

  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = "q:"
  @@PER_PAGE = 12

  def _parse_search_params

    if !params[:keywords]
      #TODO handle missing params with error page
      redirect_to('/')
      return
    end
    opts = OpenStruct.new
    opts.keywords = (params[:keywords] || []).split(",").map(&:strip)

    medium_ids = []
    studio_ids = []

    unless params[:medium].blank?
      medium_ids = params[:medium].values.map(&:to_i).reject{|v| v <= 0}
      opts.mediums = Medium.find_all_by_id(medium_ids)
    end
    unless params[:studio].blank?
      studio_ids = params[:studio].values().compact.map(&:to_i)
      opts.studios = []
      if (studio_ids && !studio_ids.empty?)
        if studio_ids.include? 0
          opts.studios << Studio.indy
          studio_ids.reject!{|s| s == 0}
        end
        if !studio_ids.empty?
          opts.studios += Studio.find_all_by_id(studio_ids)
        end
      end
    end

    opts.os_flag = { '1' => true, '2' => false }[params[:os_artist]]

    opts.page = params[:p].to_i
    
    opts.mode = params[:m]

    opts.query = opts.keywords.compact.join(" ")
    
    opts
  end

  def fetch
    execute_search
    render :layout => false
  end

  def index

    # add wildcard
    params.symbolize_keys!
    if !params[:keywords]
      #TODO handle missing params with error page
      redirect_to('/')
      return
    end
    execute_search

  end

  def execute_search
    params.symbolize_keys!

    opts = _parse_search_params
    
    results_by_kw = {}
    
    opts.keywords.map(&:downcase).each do |kw|

      kw_query_param = "%#{kw}%"
      partial_results = ArtPiece.find(:all, :conditions => ["title like ?", kw_query_param]) 
      partial_results += ((Artist.active.find(:all, :conditions => ["(firstname like ? or lastname like ?) ", kw_query_param, kw_query_param ])).map{ |a| a.art_pieces }.flatten - partial_results)
      tag_ids = ArtPieceTag.find_all_by_name(kw)
      tags = ArtPiecesTag.find(:all, :conditions => ["art_piece_tag_id in (?)", tag_ids])

      partial_results += ArtPiece.find_all_by_id( tags.map(&:art_piece_id) )

      partial_results += Artist.find(:all, :conditions => ['lower(concat(trim(firstname), \' \', trim(lastname))) = ?', kw]).map(&:art_pieces).flatten

      results_by_kw[kw] = partial_results.uniq_by{|obj| obj.id}
    end

    partial_results = results_by_kw.values.compact.flatten

    hits = histogram partial_results.map(&:id)

    num_keywords = opts.keywords.size
    partial_results.reject!{|ap| hits[ap.id] < num_keywords}

    # filter by mediums and or studios
    if opts.mediums.present?
      mids = opts.mediums.map(&:id)
      partial_results.reject!{|ap| !ap.medium_id || !mids.include?(ap.medium_id) }
    end
    if opts.studios.present?
      sids = opts.studios.map(&:id).compact
      partial_results.reject!{|ap| !ap.artist || !sids.include?(ap.artist.studio_id)}
    end
    if opts.os_flag == true
      partial_results.reject!{|ap| !ap.artist.doing_open_studios?}
    elsif opts.os_flag == false
      partial_results.reject!{|ap| ap.artist.doing_open_studios?}
    end
      
    results = {}
    begin 
      partial_results.flatten.compact.flatten.each do |entry|
        results[entry.id] = entry if entry.id and entry.artist && entry.artist.active?
      end
    rescue Exception => ex
      logger.warn("Failed to map search results %s" % ex)
    end
    
    results = results.values.sort_by { |p| p.updated_at }
    @pieces, nextpage, prevpage, curpage, lastpage = ArtPiecesHelper.compute_pagination(results, opts.page, @@PER_PAGE)
    if curpage > lastpage
      curpage = lastpage
    elsif curpage < 0
      curpage = 0
    end
    show_next = (curpage != lastpage)
    show_prev = (curpage > 0)

    @last = lastpage + 1
    @page = curpage + 1

    @user_query = opts.query || ''
    @keywords = opts.keywords || []
    @mediums = opts.mediums || []
    @studios = opts.studios || []
  end

end
