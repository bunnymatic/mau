# frozen_string_literal: true
module Admin
  class ApplicationEventsController < ::BaseAdminController
    DEFAULT_NUM_EVENTS = 100

    def index
      events = fetch_events
      respond_to do |format|
        format.html do
          @events_by_type = events.each_with_object({}) do |item, result|
            tp = item.class.name
            result[tp] = [] unless result.key? tp
            result[tp] << item
          end
        end
        format.json do
          render json: events, root: 'application_events'
        end
      end
    end

    private

    def fetch_events
      limit = application_event_params[:limit].to_i
      since_date = application_event_params[:since].presence
      limit = DEFAULT_NUM_EVENTS unless limit.positive?
      since = since_date ? Time.zone.parse(since_date) : 1.year.ago
      ApplicationEvent.by_recency.where(['created_at > ?', since]).limit(limit)
    end

    def application_event_params
      params.permit(:limit, :since)
    end
  end
end
