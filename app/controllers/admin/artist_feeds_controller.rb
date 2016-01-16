module Admin
  class ArtistFeedsController < ::BaseAdminController

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
      @feed = ArtistFeed.new(artist_feed_params)
      if @feed.save
        redir = admin_artist_feeds_path
        redirect_to(redir)
      else
        render "new_or_edit"
      end
    end

    def update
      @feed = ArtistFeed.find(params[:id])
      if @feed.update_attributes(artist_feed_params)
        flash[:notice] = 'ArtistFeed was successfully updated.'
        redirect_to(admin_artist_feeds_path)
      else
        render "new_or_edit"
      end
    end

    def destroy
      @artist_feed = ArtistFeed.find(params[:id])
      @artist_feed.destroy

      redirect_to(admin_artist_feeds_url)
    end

    private
    def artist_feed_params
      params.require(:artist_feed).permit(:url, :feed, :active)
    end

  end
end
