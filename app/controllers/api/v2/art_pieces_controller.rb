module Api
  module V2
    class ArtPiecesController < Api::ApiController
      respond_to :json, :xml
      def index
        art = Artist.find(params[:artist_id]).art_pieces
        respond_with art
      end

      def show
        art = ArtPiece.find(params[:id])
        respond_with art
      end
    end
  end
end
