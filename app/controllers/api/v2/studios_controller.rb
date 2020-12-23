# frozen_string_literal: true

require_relative '../../../serializers/studio_serializer'

module Api
  module V2
    class StudiosController < Api::ApiController
      respond_to :json, :xml
      def show
        studio = StudioService.find(params[:id])
        if !studio
          head 400
        else
          render jsonapi: studio, include: [:artists], class: mau_serializer_lut.merge(Artist: StudioArtistSerializer)

        end
      end
    end
  end
end
