module Admin
  class ApplicationEventsController < ::BaseAdminController

    DEFAULT_NUM_EVENTS = 100
    def index
      limit = params[:limit].to_i
      if limit <= 0
        limit = DEFAULT_NUM_EVENTS
      end
      events = ApplicationEvent.by_recency.limit(limit)
      respond_to do |format|
        format.html {
          @events_by_type = events.inject({}) do |result, item|
            tp = item.class.name
            result[tp] = [] unless result.has_key? tp
            result[tp] << item
            result
          end
        }
        format.json {
          render json: events, each_serializer: ApplicationEventSerializer
        }
      end
    end
  end

end
