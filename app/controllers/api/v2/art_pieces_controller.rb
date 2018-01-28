# frozen_string_literal: true

module Api
  module V2
    class ArtPiecesController < Api::ApiController
      def index
        artist = Artist.find(params[:artist_id])
        art = artist.art_pieces
        render json: art
      rescue ActiveRecord::RecordNotFound
        render json: {}
      end

      def show
        art = ArtPiece.find(params[:id])
        render json: art
      end
    end
  end
end
