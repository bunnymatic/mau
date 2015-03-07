module Admin
  class ArtistsController < AdminController
    before_filter :admin_required, :only => [ :index, :update ]
    before_filter :editor_required, :only => [ :notify_featured ]

    def index
      get_sort_options_from_params
      @artist_list = AdminArtistList.new(view_context, @sort_by, @reverse)
      respond_to do |format|
        format.html
        format.csv { render_csv_string(@artist_list.csv, @artist_list.csv_filename) }
      end
    end

    def update
      if params['os'].present?
        @updated_count = 0
        @skipped_count = 0
        os_by_artist = params['os']
        artists = Artist.active.find(os_by_artist.keys)
        for artist in artists
          update_artist_os_standing(artist, os_by_artist[artist.id.to_s] == '1')
        end
        msg = "Updated setting for %d artists" % @updated_count
        if @skipped_count > 0
          msg += " and skipped %d artists who are not in the mission or have an invalid address" % skipped_count
        end
        flash[:notice] = msg
      end
      redirect_to(admin_artists_url)
    end

    def notify_featured
      id = Integer(params[:id])
      ArtistMailer.notify_featured(Artist.find(id)).deliver!
      render :layout => false, :nothing => true, :status => :ok
    end

    private
    def get_sort_options_from_params
      @sort_by = params[:sort_by] || params[:rsort_by]
      @reverse = params.has_key? :rsort_by
    end

    def update_artist_os_standing(artist, doing_it)
      if artist.doing_open_studios? != doing_it
        if artist.has_address?
          artist.update_os_participation OpenStudiosEvent.current, doing_it
          @updated_count += 1
        else
          @skipped_count += 1
        end
      end
    end

  end


end
