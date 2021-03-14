module Admin
  class ArtistsController < ::BaseAdminController
    before_action :admin_required, only: %i[suspend index edit update]
    before_action :set_artist, only: %i[edit suspend update]

    def index
      artist_list = AdminArtistList.new
      respond_to do |format|
        format.html do
          @artist_counts = {
            active: artist_list.good_standing_artists.count,
            pending: artist_list.pending_artists.count,
            inactive: artist_list.bad_standing_artists.count,
          }
        end

        format.csv { render_csv_string(artist_list.csv, artist_list.csv_filename) }
      end
    end

    def pending
      artist_list = AdminArtistList.new
      render partial: 'admin_artists_table', locals: {
        artist_list: artist_list.pending_artists.map { |a| ArtistPresenter.new(a) },
      }
    end

    def good_standing
      artist_list = AdminArtistList.new
      render partial: 'admin_artists_table', locals: {
        artist_list: artist_list.good_standing_artists.map { |a| ArtistPresenter.new(a) },
      }
    end

    def bad_standing
      artist_list = AdminArtistList.new
      render partial: 'admin_artists_table', locals: {
        artist_list: artist_list.bad_standing_artists.map { |a| ArtistPresenter.new(a) },
      }
    end

    def edit; end

    def update
      if @artist.update(artist_params)
        redirect_to admin_user_path(@artist)
      else
        render :edit, warning: 'There were problems updating the artist'
      end
    end

    def suspend
      SuspendArtistService.new(@artist).suspend!
      redirect_to admin_artists_path, notice: "#{@artist.get_name} has been suspended"
    end

    def bulk_update
      _success, message = AdminArtistUpdateService.bulk_update_os(os_update_params)

      redirect_to(admin_artists_url, message)
    end

    private

    def set_artist
      @artist = Artist.find(params[:id])
    end

    def os_update_params
      params.require(:os).permit!
    end

    def artist_params
      allowed_links = Artist.stored_attributes[:links]
      open_studios_participant_fields = [
        :id,
        :shop_url,
        :youtube_url,
        :video_conference_url,
        :show_phone_number,
        :show_email,
        { video_conference_schedule: {} },
      ]
      params.require(:artist).permit(:firstname, :lastname,
                                     :email, :nomdeplume,
                                     :studio_id,
                                     links: allowed_links,
                                     artist_info_attributes: %i[studionumber street bio],
                                     open_studios_participants_attributes: open_studios_participant_fields).tap do |prms|
        prms[:open_studios_participants_attributes]&.each do |idx, entry|
          entry[:video_conference_schedule]&.each do |timeslot, val|
            prms[:open_studios_participants_attributes][idx][:video_conference_schedule][timeslot] = (val == '1')
          end
        end
      end
    end
  end
end
