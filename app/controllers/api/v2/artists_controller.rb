module Api
  module V2
    class ArtistsController < Api::ApiController
      respond_to :json, :xml
      def show
        artist = Artist.find(params[:id])
        respond_with artist
      end
    end
  end
end
