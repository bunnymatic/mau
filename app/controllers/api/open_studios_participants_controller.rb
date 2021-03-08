module Api
  class OpenStudiosParticipantsController < ApiController
    include UserControllerHelpers

    before_action :artist_required

    def update
      @participant = OpenStudiosParticipant.find(params[:id])
      if current_artist.id != @participant.user_id
        render json: {}, status: :unauthorized
        return
      end

      if @participant.update(open_studios_participant_params)
        render json: @participant
      else
        render json: { errors: @participant.errors }, status: :bad_request
      end
    end

    private

    def open_studios_participant_params
      params.require(:open_studios_participant).permit(
        :shop_url,
        :show_email,
        :show_phone_number,
        :video_conference_url,
        :youtube_url,
        video_conference_schedule: {},
      ).tap do |prms|
        prms[:video_conference_schedule]&.each do |k, v|
          prms[:video_conference_schedule][k] = (v == 'true')
        end
      end
    end
  end
end
