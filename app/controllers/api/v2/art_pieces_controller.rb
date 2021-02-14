module Api
  module V2
    class ArtPiecesController < Api::ApiController
      def index
        artist = Artist.find(params[:artist_id])
        art = artist.art_pieces
        render jsonapi: art, include: %i[medium tags]
      rescue ActiveRecord::RecordNotFound
        render json: {}
      end

      def show
        art = ArtPiece.find(params[:id])
        render jsonapi: art, include: %i[medium tags]
      end
    end
  end
end
