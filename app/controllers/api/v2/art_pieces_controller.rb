# frozen_string_literal: true
module Api
  module V2
    class ArtPiecesController < Api::ApiController
      respond_to :json, :xml
      def index
        artist = Artist.find(params[:artist_id])
        art = artist.art_pieces
        respond_with art
      rescue ActiveRecord::RecordNotFound => ex
        render json: {}
      end

      def show
        art = ArtPiece.find(params[:id])
        respond_with art
      end
    end
  end
end
