class SearchController < ApplicationController

  def index
    return unless execute_search
  end

  def fetch
    respond_to do |format|
      format.html {
        execute_search
        render :layout => false
      }
      format.json {
        @query = SearchQuery.new(params)
        results = SearchService.new(@query).search
        @results = results
      }
    end
  end

  private


  def parse_search_params
  end

  PER_PAGE_OPTS = [12,24,48,96].freeze

  def per_page_options(results)
    @per_page_options ||= PER_PAGE_OPTS[0..PER_PAGE_OPTS.select{|v| v < results.count}.count]
  end

  def execute_search
    @query = SearchQuery.new(params)

    results = SearchService.new(@query).search.map{|ap| ArtPiecePresenter.new(view_context, ap)}
    
    @per_page_opts = per_page_options(results)
    @query.per_page = results.count < @query.per_page ? @per_page_opts.max : @query.per_page

    @paginator = Pagination.new(view_context, results, @query.page, @query.per_page)

  end

end
