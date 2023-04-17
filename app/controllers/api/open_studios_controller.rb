module Api
  class OpenStudiosController < Api::ApiController
    def map
      @map_info = ArtistsMap.new(os_only: true)

      render json: {
        map_markers: @map_info.map_data,
        map_bounds: @map_info.bounds,
      }
    end
  end
end
