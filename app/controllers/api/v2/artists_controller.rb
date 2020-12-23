# frozen_string_literal: true

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

      def show
        artist = Artist.active.friendly.find(params[:id])
        render jsonapi: artist
      end
    end
  end
end
