module Api
  module V2
    class ArtPiecesController < Api::ApiController
      def index
        num_pieces = params[:count].presence && Integer(params[:count])
        artist = Artist.find(params[:artist_id])
        art = artist.art_pieces
        art = artist.art_pieces.limit(num_pieces) if num_pieces
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
