module Admin
  class ApplicationEventsController < ::BaseAdminController

    DEFAULT_NUM_EVENTS = 100

    def index
      events = fetch_events
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
    def fetch_events
      limit = application_event_params[:limit].to_i
      since_date = application_event_params[:since].presence
      limit = DEFAULT_NUM_EVENTS unless limit.positive?
      since = since_date ? Time.zone.parse(since_date) : 1.year.ago
      events = ApplicationEvent.by_recency.where(["created_at > ?", since]).limit(limit)
    end

    def application_event_params
      params.permit(:limit, :since)
    end

  end

end
