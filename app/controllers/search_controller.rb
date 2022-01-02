class SearchController < ApplicationController
  LIMIT = 40

  def index
    @query = params[:q]
    respond_to do |format|
      format.html {}
      format.json do
        render json: json_results[0..LIMIT].to_json
      end
    end
  end

  private

  def search_results
    @search_results ||= Search::QueryRunner.new(@query).search.group_by(&:_type)
  end

  def json_results
    search_results.values.each_with_object([]) { |hits, results| results.concat(hits) }.sort_by { |hit| -hit._score }.map(&:as_json)
  end
end
