module Api
  class ArtistsController < ApiController
    include UserControllerHelpers

    before_action :artist_required

    def register_for_open_studios
      # this is set in ArtistsController#register_for_open_studios
      # a bit of a disconnect there but for now...
      # this note may suffice
      flash.discard(:registering_for_open_studios)
      if current_artist.can_register_for_open_studios?
        participant = UpdateArtistService.new(current_artist, os_participation: params[:participation]).update_os_status

        render json: {
          success: true,
          participant: participant.as_json(root: false),
        }
      else
        render json: { success: false, participant: nil }, status: :bad_request
      end
    end
  end
end
