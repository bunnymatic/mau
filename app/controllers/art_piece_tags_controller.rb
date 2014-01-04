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
    tags = ArtPieceTag.all
    freq = ArtPieceTag.keyed_frequency
    tags.each do |t|
      if freq.keys.include? t.id
        t['count'] = freq[ t.id ].to_f
      else
        t['count'] = 0
      end
    end
    @tags = tags.sort { |a,b| b['count'] <=> a['count'] }
    render :layout => "mau-admin"
  end

  def cleanup
    tags = ArtPieceTag.all
    freq = ArtPieceTag.keyed_frequency
    tags.each do |t|
      if freq.keys.include? t.id
        t['count'] = freq[ t.id ].to_f
      else
        t['count'] = 0
      end
    end
    @tags = tags.sort { |a,b| a['count'] <=> b['count'] }
    @tags.each do |t|
      if t['count'] <= 0
        t.destroy
      end
    end
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

    @results_mode = params[:m] || 'p'

    @tag_presenter = ArtPieceTagPresenter.new(@tag, @results_mode)
    @pieces = @tag_presenter.art_pieces
    @tag_cloud_presenter = TagCloudPresenter.new(view_context, ArtPieceTag, @tag, @results_mode)
    @paginator = ArtPieceTagPagination.new(view_context, @pieces, @tag, page, {:m => @results_mode})

    @by_artists_link = art_piece_tag_url(@tag, { :m => 'a' })
    @by_pieces_link = art_piece_tag_url(@tag, { :m => 'p' })

    render :action => "show", :layout => "mau"
  end

  def new
    @tag = ArtPieceTag.new
    ArtPieceTag.flush_cache
  end

  def create
    @tag = ArtPieceTag.new(params[:tag])

    if @tag.save
      ArtPieceTag.flush_cache
      flash[:notice] = 'ArtPieceTag was successfully created.'
      redirect_to(@tag)
    else
      render :action => "new"
    end

  end

  def destroy
    @tag = ArtPieceTag.find(params[:id])
    @tag.destroy
    ArtPieceTag.flush_cache
    redirect_to(art_piece_tags_url)
  end

  private
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
