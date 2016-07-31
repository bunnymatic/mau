module Admin
  class ApplicationEventsController < ::BaseAdminController

    DEFAULT_NUM_EVENTS = 100
    def index
      limit = params[:limit].to_i
      since_date = params[:since]
      if limit <= 0
        limit = DEFAULT_NUM_EVENTS
      end
      if since_date
        since = Time.zone.parse(since_date)
      else
        since = 1.year.ago
      end
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
  end

end
