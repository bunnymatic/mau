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
    respond_to do |format|
      if @feed.save
        redir = artist_feeds_path
        format.html { redirect_to(redir) }
        format.xml  { render :xml => @artist_feed, :status => :created, :location => @artist_feed }
      else
        format.html { render "new_or_edit"}
        format.xml  { render :xml => @artist_feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  def update
    @feed = ArtistFeed.find(params[:id])
    artist_feed_details = params[:artist_feed]
    if artist_feed_details[:artist_list]
      artist_list = artist_feed_details[:artist_list]
      artist_feed_details.delete :artist_list
    end

    respond_to do |format|
      if @feed.update_attributes(artist_feed_details)
        flash[:notice] = 'ArtistFeed was successfully updated.'
        format.html { redirect_to(artist_feeds_path) }
        format.xml  { head :ok }
      else
        format.html { render "new_or_edit", :layout => 'mau-admin' }
        format.xml  { render :xml => @feed.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @artist_feed = ArtistFeed.find(params[:id])
    @artist_feed.destroy

    respond_to do |format|
      format.html { redirect_to(artist_feeds_url) }
      format.xml  { head :ok }
    end
  end
end
