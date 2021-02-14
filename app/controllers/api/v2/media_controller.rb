module Api
  module V2
    class MediaController < Api::ApiController
      respond_to :json, :xml
      def index
        respond_with Medium.all
      end

      def show
        m = Medium.find(params[:id])
        respond_with m
      end
    end
  end
end
