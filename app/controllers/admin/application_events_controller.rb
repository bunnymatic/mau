module Admin
  class ApplicationEventsController < ::BaseAdminController

    DEFAULT_NUM_EVENTS = 100
    def index
      limit = application_event_params[:limit].to_i
      since_date = application_event_params[:since].presence
      if limit <= 0
        limit = DEFAULT_NUM_EVENTS
      end
      since = since_date ? Time.zone.parse(since_date) : 1.year.ago
      events = ApplicationEvent.by_recency.where(["created_at > ?", since]).limit(limit)
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
          render json: events, root: "application_events"
        }
      end
    end

    private

    def application_event_params
      params.permit(:limit, :since)
    end

  end

end
