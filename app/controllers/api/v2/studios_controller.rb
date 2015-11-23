module Api
  module V2
    class StudiosController < Api::ApiController
      respond_to :json, :xml
      def show
        studio = StudioService.find(params[:id])
        if !studio
          render json: {}, status: 400
        else
          render json: studio, serializer: StudioSerializer
        end
      end
    end
  end
end
