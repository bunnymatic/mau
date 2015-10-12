module Api
  module V2
    class ArtPiecesController < Api::ApiController
      respond_to :json, :xml
      def show
        art = ArtPiece.find(params[:id])
        respond_with art
      end
    end
  end
end
