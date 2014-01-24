require 'json'
require 'json/add/core'
#require 'json/add/rails'
class ArtPieceTagsController < ApplicationController
  layout 'mau1col'
  before_filter :admin_required, :except => [ :index, :show, :autosuggest ]
  after_filter :store_location

  AUTOSUGGEST_CACHE_EXPIRY = Conf.autosuggest['tags']['cache_expiry']
  AUTOSUGGEST_CACHE_KEY = Conf.autosuggest['tags']['cache_key']

  def admin_index
    @tags = tags_sorted_by_frequency
    render :layout => "mau-admin"
  end

  def cleanup
    @tags = tags_sorted_by_frequency
    @tags.each {|(tag, ct)| tag.destroy if ct <= 0 }
    redirect_to '/admin/art_piece_tags'
  end

  def autosuggest
    tags = fetch_tags_for_autosuggest
    if params[:input]
      # filter with input prefix
      inp = params[:input].downcase
      tags = (inp.present? ? tags.select{|tag| tag['value'].downcase.starts_with? inp} : [])
    end
    render :json => tags
  end

  def index
    respond_to do |format|
      format.html { redirect_to_most_popular_tag }
      format.json {
        tags = ArtPieceTag.all
        render :json => tags
      }
    end
  end

  # GET /tags/1
  def show
    if is_mobile?
      redirect_to root_path and return
    end
    # get art pieces by tag
    @tag = ArtPieceTag.find(params[:id])
    page = 0
    if params[:p]
      page = params[:p].to_i
    end

    mode = params[:m]
    @tag_presenter = ArtPieceTagPresenter.new(@tag, mode)
    @tag_cloud_presenter = TagCloudPresenter.new(view_context, ArtPieceTag, @tag, :mode)
    @paginator = ArtPieceTagPagination.new(view_context, @tag_presenter.art_pieces, @tag, page, params[:m])

    @by_artists_link = art_piece_tag_url(@tag, { :m => 'a' })
    @by_pieces_link = art_piece_tag_url(@tag, { :m => 'p' })

    render :action => "show", :layout => "mau"
  end

  def destroy
    @tag = ArtPieceTag.find(params[:id])
    @tag.destroy
    ArtPieceTag.flush_cache
    redirect_to(art_piece_tags_url)
  end

  private

   def tags_sorted_by_frequency
    all_tags = ArtPieceTag.all
    freq = ArtPieceTag.keyed_frequency
    all_tags.map do |tag|
      [tag, freq[tag.id].to_f]
    end.select(&:first).sort_by(&:last).reverse
  end

  def fetch_tags_for_autosuggest
    tags = SafeCache.read(AUTOSUGGEST_CACHE_KEY)
    unless tags
      tags = ArtPieceTag.all.map{|t| { "value" => t.name, "info" => t.id }}
      if tags.present?
        SafeCache.write(AUTOSUGGEST_CACHE_KEY, tags, :expires_in => AUTOSUGGEST_CACHE_EXPIRY)
      end
    end
    tags
  end

  def redirect_to_most_popular_tag
    xtra_params = params.slice(:m, 'm')
    freq = ArtPieceTag.frequency
    if !freq || freq.empty?
      render_not_found Exception.new("No tags in the system")
    else
      redirect_to art_piece_tag_path(freq.first['tag'], xtra_params)
    end
  end
end
