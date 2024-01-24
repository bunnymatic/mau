module Api
  module V2
    class ArtistsController < Api::ApiController
      def index
        artists = []
        if params[:studio]
          studio = Studio.find(params[:studio])
          artists = Artist.active.where(studio_id: studio.id) if studio
        end
        render jsonapi: artists
      end

      def ids
        artists = Artist.none
        if params[:studio]
          studio = Studio.find(params[:studio])
          artists = Artist.active.where(studio_id: studio.id)
        end
        render json: { artist_ids: artists.pluck(:id) }
      rescue ActiveRecord::RecordNotFound
        render json: { artist_ids: [] }
      end

      def show
        artist = Artist.active.friendly.find(params[:id])
        render jsonapi: artist
      end
    end
  end
end
