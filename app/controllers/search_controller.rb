class SearchController < ApplicationController

  def index
    @query = SearchQuery.new(params)
    return unless execute_search
  end

  # elastic search search
  def search
    @query = params[:q]
    @search_results = EsSearchService.new(nil, @query).search.group_by(&:_type)
    
    respond_to do |format|
      format.html {}
      format.json {
        results = []
        @search_results.each do |model, hits|
          hits.each do |hit|
            results << hit.to_h.slice(:_type, :_score, :_id, :_source)
          end
        end
        render json: results.sort_by{|r| r['_score']}
      }
    end
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
