# frozen_string_literal: true
class SearchController < ApplicationController
  LIMIT = 40

  def index
    @query = params[:q]
    respond_to do |format|
      format.html {}
      format.json do
        render json: json_results.sort_by { |r| -1.0 * r[:_score] }[0..LIMIT]
      end
    end
  end

  private

  def search_results
    @search_results ||= Search::QueryRunner.new(@query).search.group_by(&:_type)
  end

  def json_results
    [].tap do |results|
      search_results.each do |_model, hits|
        hits.each do |hit|
          results << hit.to_h.slice(:_type, :_score, :_id, :_source)
        end
      end
    end
  end
end
