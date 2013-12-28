def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

class SearchController < ApplicationController
  layout 'mau'

  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = "q:"
  PER_PAGE = 12

  def _parse_search_params
    opts = OpenStruct.new
    opts.keywords = (params[:keywords] || '').split(",").map(&:strip)

    medium_ids = []
    studio_ids = []

    unless params[:medium].blank?
      medium_ids = params[:medium].values.map(&:to_i).reject{|v| v <= 0}
      opts.mediums = Medium.where(:id => medium_ids).order('name')
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
          opts.studios += Studio.where(:id => studio_ids)
        end
      end
    end

    opts.os_flag = { '1' => true, '2' => false }[params[:os_artist]]

    opts.page = params[:p].to_i

    opts.mode = params[:m]

    opts.query = opts.keywords.compact.join(", ")

    opts.per_page = (params[:per_page] || PER_PAGE).to_i
    opts
  end

  def fetch
    execute_search
    render :layout => false
  end

  def index
    return unless execute_search
  end

  def execute_search

    opts = _parse_search_params

    results = MauSearch.new(opts).search

    num_results = results.count
    per_page_opts = [12,24,48,96]
    @per_page_opts = per_page_opts[0..per_page_opts.select{|v| v < num_results}.count]

    opts.per_page = num_results < opts.per_page ? @per_page_opts.max : opts.per_page

    @paginator = Pagination.new(results, opts.page, opts.per_page)
    # @pieces = @paginator.items
    curpage = @paginator.current_page
    lastpage = @paginator.last_page

    @last = lastpage + 1
    @page = curpage + 1

    if @paginator.count <= 12
      @per_page_opts = nil
    end
    @per_page = opts.per_page
    @user_query = opts.query || ''
    @keywords = opts.keywords || []
    @mediums = opts.mediums || []
    @studios = opts.studios || []

  end

end
