def histogram inp; hash = Hash.new(0); inp.each {|k,v| hash[k]+=1}; hash; end

class SearchController < ApplicationController
  layout 'mau'

  @@CACHE_EXPIRY = (Conf.cache_expiry['search'] or 20)
  @@QUERY_KEY_PREFIX = "q:"

  def fetch
    execute_search
    render :layout => false
  end

  def index
    return unless execute_search
  end

  private


  def parse_search_params
  end

  PER_PAGE_OPTS = [12,24,48,96].freeze

  def per_page_options(results)
    @per_page_options ||= PER_PAGE_OPTS[0..PER_PAGE_OPTS.select{|v| v < results.count}.count]
  end

  def execute_search

    @query = MauSearchQuery.new(params)

    results = MauSearch.new(@query).search

    @per_page_opts = per_page_options(results)
    @query.per_page = results.count < @query.per_page ? @per_page_opts.max : @query.per_page

    @paginator = Pagination.new(view_context, results, @query.page, @query.per_page)

    #   @per_page = opts.per_page
    # @user_query = opts.query || ''
    # @keywords = opts.keywords || []
    # @mediums = opts.mediums || []
    # @studios = opts.studios || []

  end

end
