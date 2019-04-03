# frozen_string_literal: true

module Api
  class ArtistsController < ApiController
    include UserControllerHelpers

    before_action :artist_required

    def register_for_open_studios
      if current_artist.can_register_for_open_studios?
        participation = UpdateArtistService.new(current_artist, os_participation: params[:participation]).update_os_status
        render json: { success: true, participating: participation }
      else
        render json: { success: false, participating: false }, status: :bad_request
      end
    end
  end
end