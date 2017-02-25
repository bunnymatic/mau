# frozen_string_literal: true
module Admin
  class ArtistsController < ::BaseAdminController
    before_action :admin_required, only: [:suspend, :index, :edit, :update]
    before_action :set_artist, only: [:edit, :suspend, :update]

    def index
      @artist_list = AdminArtistList.new
      @active_artist_list, @inactive_artist_list = @artist_list.partition { |a| a.pending? || a.active? }
      respond_to do |format|
        format.html
        format.csv { render_csv_string(@artist_list.csv, @artist_list.csv_filename) }
      end
    end

    def edit; end

    def update
      if @artist.update_attributes(artist_params)
        redirect_to admin_user_path(@artist), notice: "#{@artist.get_name} has been updated"
      else
        render :edit, warning: 'There were problems updating the artist'
      end
    end

    def suspend
      SuspendArtistService.new(@artist).suspend!
      redirect_to admin_artists_path, notice: "#{@artist.get_name} has been suspended"
    end

    def bulk_update
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
        msg = 'Updated setting for %d artists' % @updated_count
        if @skipped_count > 0
          msg += ' and skipped %d artists who are not in the mission or have an invalid address' % @skipped_count
        end
        flash[:notice] = msg
      end
      redirect_to(admin_artists_url)
    end

    private

    def set_artist
      @artist = Artist.find(params[:id])
    end

    # return ternary - nil if the artist was skipped, else true if the artist setting was changed, false if not
    # TODO: move to UpdateArtistService?  or AdminUpdateArtistService?
    def update_artist_os_standing(artist, current_open_studios, doing_it)
      return nil unless artist.has_address?
      if artist.doing_open_studios? != doing_it
        artist.update_os_participation current_open_studios, doing_it
        true
      else
        false
      end
    end

    def artist_params
      allowed_links = Artist.stored_attributes[:links]
      params.require(:artist).permit(:firstname, :lastname,
                                     :email, :nomdeplume,
                                     :studio_id,
                                     links: allowed_links,
                                     artist_info_attributes: [:studionumber, :street, :bio])
    end
  end
end
