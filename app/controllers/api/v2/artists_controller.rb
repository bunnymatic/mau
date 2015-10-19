module Api
  module V2
    class ArtistsController < Api::ApiController
      respond_to :json, :xml
      def index
        artists = []
        if params[:studio]
          studio = Studio.find(params[:studio])
          artists = Artist.where(studio_id: studio.id) if studio
        end
        respond_with artists
      end

      def show
        artist = Artist.find(params[:id])
        respond_with artist
      end
    end
  end
end
