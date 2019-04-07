# frozen_string_literal: true

module Admin
  class ApplicationEventsController < ::BaseAdminController
    def index
      query = ApplicationEventQuery.new(application_event_params)

      if query.valid?
        @query = query
      else
        flash.now[:error] = query.errors.full_messages.to_sentence + '. Falling back to the defaults.' unless application_event_params.empty?
        @query = ApplicationEventQuery.new
      end
      events = ApplicationEventFetcher.run(@query)
      respond_to do |format|
        format.html do
          @events_by_type = events
        end
        format.json do
          render json: events.values.flatten, root: 'application_events'
        end
      end
    end

    private

    def application_event_params
      return {} unless params.key?(:query)

      params.require(:query).permit(:number_of_records, :since)
    end
  end
end
