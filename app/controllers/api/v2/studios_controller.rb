module Api
  module V2
    class StudiosController < Api::ApiController
      respond_to :json, :xml
      def show
        studio = StudioService.find(params[:id])
        if studio
          render jsonapi: studio
        else
          head :bad_request

        end
      end
    end
  end
end
