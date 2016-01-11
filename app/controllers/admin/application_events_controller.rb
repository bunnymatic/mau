module Admin
  class ApplicationEventsController < ::BaseAdminController

    def index
      @events_by_type = ApplicationEvent.by_recency.inject({}) do |result, item|
        tp = item.class.name
        result[tp] = [] unless result.has_key? tp
        result[tp] << item
        result
      end
    end
  end

end
