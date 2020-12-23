# frozen_string_literal: true

require_relative '../serializers/art_piece_tag_serializer'

class ArtPieceTagsController < ApplicationController
  class NoTagsError < StandardError; end

  before_action :admin_required, except: %i[index show autosuggest]

  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['tags']['cache_expiry']
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['tags']['cache_key']

  def autosuggest
    tags = fetch_tags_for_autosuggest
    q = query_input_params
    if q.present?
      # filter with input prefix
      inp = q.downcase
      tags = tags.select { |tag| tag.name.downcase.starts_with? inp }
    end
    render json: { "art_piece_tags": tags.map { |t| t.class == ArtPieceTag ? t : ArtPieceTag.new(t) } }
  end

  def index
    respond_to do |format|
      format.html { redirect_to_most_popular_tag }
      format.json do
        tags = ArtPieceTag.all
        render jsonapi: tags
      end
    end
  end

  # GET /tags/1
  def show
    # get art pieces by tag
    begin
      @tag = ArtPieceTag
             .friendly
             .includes(art_pieces_tags: { art_piece: { artist: :open_studios_events } })
             .find(params[:id])
    rescue ActiveRecord::RecordNotFound
      redirect_to_most_popular_tag(flash: { error: "Sorry, we can't find the tag you were looking for" }) && (return)
    end

    page = show_tag_params[:p].to_i

    @tag_presenter = ArtPieceTagPresenter.new(@tag, page)
    @tag_cloud_presenter = TagCloudPresenter.new(@tag)
    @paginator = @tag_presenter.paginator
  end

  private

  def fetch_tags_for_autosuggest
    tags = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    unless tags
      tags = ArtPieceTag.select('id', 'name')
      SafeCache.write(AUTOSUGGEST_CACHE_KEY, tags, expires_in: AUTOSUGGEST_CACHE_EXPIRY) if tags.present?
    end
    tags
  end

  def redirect_to_most_popular_tag(redirect_opts = {})
    popular_tag = ArtPieceTagService.most_popular_tag
    if popular_tag.nil?
      render_not_found NoTagsError.new('No tags in the system')
    else
      redirect_to art_piece_tag_path(popular_tag, show_tag_params), redirect_opts
    end
  end

  def show_tag_params
    params.permit(:p)
  end

  def query_input_params
    params.permit(:q)[:q]
  end
end
