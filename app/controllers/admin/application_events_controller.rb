module Admin
  class ApplicationEventsController < ::BaseAdminController

    DEFAULT_NUM_EVENTS = 100
    def index
      limit = params[:limit].to_i
      if limit <= 0
        limit = DEFAULT_NUM_EVENTS
      end
      @events_by_type = ApplicationEvent.by_recency.limit(limit).inject({}) do |result, item|
        tp = item.class.name
        result[tp] = [] unless result.has_key? tp
        result[tp] << item
        result
      end
    end
  end

end
