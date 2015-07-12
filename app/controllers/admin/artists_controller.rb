module Admin
  class ArtistsController < BaseAdminController
    before_filter :admin_required, :only => [ :index, :update ]
    before_filter :editor_required, :only => [ :notify_featured ]

    def index
      get_sort_options_from_params
      @artist_list = AdminArtistList.new(@sort_by, @reverse)
      respond_to do |format|
        format.html
        format.csv { render_csv_string(@artist_list.csv, @artist_list.csv_filename) }
      end
    end

    def suspend
      artist = Artist.find(params[:id])
      artist.suspend!
      redirect_to admin_artists_path, notice: "#{artist.get_name} has been suspended"
    end

    def update
      current_open_studios = OpenStudiosEventService.current
      
      if current_open_studios.nil?
        flash[:error] = "You must have an Open Studios Event in the future before you can set artists' status."
      elsif params['os'].present?
        @updated_count = 0
        @skipped_count = 0
        os_by_artist = params['os']
        artists = Artist.active.where(id: os_by_artist.keys)
        for artist in artists
          changed = update_artist_os_standing(artist, current_open_studios, os_by_artist[artist.id.to_s] == '1')
          if changed.nil?
            @skipped_count += 1
          elsif changed
            @updated_count += 1
          end
        end
        msg = "Updated setting for %d artists" % @updated_count
        if @skipped_count > 0
          msg += " and skipped %d artists who are not in the mission or have an invalid address" % @skipped_count
        end
        flash[:notice] = msg
      end
      redirect_to(admin_artists_url)
    end

    def destroy
      @os_event = OpenStudiosEventService.find(params[:id], false)
      OpenStudiosEventService.destroy(@os_event)
      redirect_to admin_open_studios_events_path, notice: "The Event has been removed"
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

    # return ternary - nil if the artist was skipped, else true if the artist setting was changed, false if not
    def update_artist_os_standing(artist, current_open_studios, doing_it)
      return nil unless artist.has_address?
      artist.update_os_participation current_open_studios, (artist.doing_open_studios? != doing_it)
      return (artist.doing_open_studios? != doing_it)
    end

  end


end
