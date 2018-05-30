# frozen_string_literal: true

module Api
  class ArtistsController < ApiController
    include UserControllerHelpers

    before_action :artist_required

    def register_for_open_studios
      success = UpdateArtistService.new(current_artist, os_participation: 1).update_os_status

      status = success ? :ok : :bad_request
      render json: { success: success }, status: status
    end
  end
end
