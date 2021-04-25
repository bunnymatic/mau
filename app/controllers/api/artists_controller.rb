module Api
  class ArtistsController < ApiController
    include UserControllerHelpers

    before_action :artist_required

    def register_for_open_studios
      participant = UpdateArtistService.new(current_artist, os_participation: params[:participation]).update_os_status

      render json: {
        success: true,
        participant: participant.as_json(root: false),
      }
    end
  end
end
