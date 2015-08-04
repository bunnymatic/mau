class SearchController < ApplicationController

  def index
    @query = SearchQuery.new(params)
    return unless execute_search
  end

  # elastic search search
  def search
    @query = params[:q]
    @studio_results = EsSearchService.new(nil, @query).search
    @artist_results = [] #EsSearchService.new(Artist, @query).search
    @art_piece_results = [] # EsSearchService.new(ArtPiece, @query).search
  end
  
  def fetch
    @query = SearchQuery.new(params)
    respond_to do |format|
      format.html {
        execute_search
        render :layout => false
      }
      format.json {
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
    results = SearchService.new(@query).search.map{|ap| ArtPiecePresenter.new(ap)}

    @per_page_opts = per_page_options(results)
    @query.per_page = results.count < @query.per_page ? @per_page_opts.max : @query.per_page

    @paginator = Pagination.new(results, @query.page, @query.per_page)

  end

end
