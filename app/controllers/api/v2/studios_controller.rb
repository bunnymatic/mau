module Api
  module V2
    class StudiosController < Api::ApiController
      respond_to :json, :xml
      def index
        respond_with Studio.all
      end
      def show
        studio = StudioService.find(params[:id])
        respond_with studio
      end
    end
  end
end
