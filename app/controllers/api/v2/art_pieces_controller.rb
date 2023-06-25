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

      def image
        art = ArtPiece.find(params[:art_piece_id])
        render json: { id: art.id, url: art.image(image_size_from_attrs) }
      end

      private

      def image_size_from_attrs
        params.require(:size)
      end
    end
  end
end
