class ArtistFeedsController < ApplicationController

  before_filter :admin_required
  layout 'mau-admin'

  def index
    @feeds = ArtistFeed.all
  end

  def new
    @feed = ArtistFeed.new(:active => true)
    render 'new_or_edit' and return
  end

  # GET /events/1/edit
  def edit
    @feed = ArtistFeed.find(params[:id])
    render 'new_or_edit' and return
  end

  def create
    @feed = ArtistFeed.new(params[:artist_feed])
    if @feed.save
      redir = artist_feeds_path
      redirect_to(redir)
    else
      render "new_or_edit"
    end
  end

  def update
    @feed = ArtistFeed.find(params[:id])
    artist_feed_details = params[:artist_feed]
    if artist_feed_details[:artist_list]
      artist_list = artist_feed_details[:artist_list]
      artist_feed_details.delete :artist_list
    end

    if @feed.update_attributes(artist_feed_details)
      flash[:notice] = 'ArtistFeed was successfully updated.'
      redirect_to(artist_feeds_path)
    else
      render "new_or_edit", :layout => 'mau-admin'
    end
  end

  def destroy
    @artist_feed = ArtistFeed.find(params[:id])
    @artist_feed.destroy

    redirect_to(artist_feeds_url)
  end
end
