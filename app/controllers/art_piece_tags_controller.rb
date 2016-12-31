class ArtPieceTagsController < ApplicationController

  before_action :admin_required, except: [ :index, :show, :autosuggest ]

  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['tags']['cache_expiry']
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['tags']['cache_key']

  def autosuggest
    tags = fetch_tags_for_autosuggest
    q = query_input_params
    if q.present?
      # filter with input prefix
      inp = q.downcase
      tags = tags.select{|tag| tag['value'].downcase.starts_with? inp}
    end
    render json: tags.map{|t| t['value']}, root: false
  end

  def index
    respond_to do |format|
      format.html { redirect_to_most_popular_tag }
      format.json {
        tags = ArtPieceTag.all
        render json: tags
      }
    end
  end

  # GET /tags/1
  def show
    # get art pieces by tag
    begin
      @tag = ArtPieceTag.friendly.find(params[:id])
    rescue ActiveRecord::RecordNotFound => ex
      redirect_to_most_popular_tag(flash: { error: "Sorry, we can't find the tag you were looking for"} ) and return
    end

    page = show_tag_params[:p].to_i
    mode = show_tag_params[:m]

    @tag_presenter = ArtPieceTagPresenter.new(@tag, mode)
    @tag_cloud_presenter = TagCloudPresenter.new(ArtPieceTag, @tag, mode)
    @paginator = ArtPieceTagPagination.new(@tag_presenter.art_pieces, @tag, page, mode)

    @by_artists_link = art_piece_tag_url(@tag, { m: 'a' })
    @by_pieces_link = art_piece_tag_url(@tag, { m: 'p' })
  end


  private
  def fetch_tags_for_autosuggest
    tags = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    unless tags
      tags = ArtPieceTag.all.map{|t| { "value" => t.name, "info" => t.id }}
      if tags.present?
        SafeCache.write(AUTOSUGGEST_CACHE_KEY, tags, expires_in: AUTOSUGGEST_CACHE_EXPIRY)
      end
    end
    tags
  end

  def redirect_to_most_popular_tag(redirect_opts={})
    popular_tag = ArtPieceTagService.most_popular_tag
    if popular_tag.nil?
      render_not_found Exception.new("No tags in the system")
    else
      redirect_to art_piece_tag_path(popular_tag, show_tag_params), redirect_opts
    end
  end

  def show_tag_params
    params.permit(:p, :m)
  end

  def query_input_params
    params.permit(:q)[:q]
  end
end
