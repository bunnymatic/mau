module Api
  module V2
    class ContactsController < Api::ApiController
      layout false
      skip_before_action :require_authorization

      def create
        contact_info = ContactArtistAboutArtFormData.new(contact_params)
        if contact_info.valid?
          ContactArtistService.contact_about_art(contact_info)
          head :ok
        else
          render json: { errors: contact_info.errors }, status: :bad_request
        end
      end

      def contact_params
        params.permit(:name, :email, :phone, :message, :art_piece_id)
      end
    end
  end
end
