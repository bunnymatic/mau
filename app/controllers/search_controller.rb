class SearchController < ApplicationController

  def index
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

end
