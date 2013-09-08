class CalendarController < ApplicationController
  include EventsHelper
  layout 'mau2col'
  def index
    @month = (params[:month] || (Time.zone || Time).now.month).to_i
    @year = (params[:year] || (Time.zone || Time).now.year).to_i

    @shown_month = Date.civil(@year, @month)

    start_d, end_d = Event.get_start_and_end_dates(@shown_month) # optionally pass in @first_day_of_week
    @events = Event.published.events_for_date_range(start_d, end_d)
    @event_strips = Event.create_event_strips(start_d, end_d, @events)

    published_events, @events_by_month = fetch_published_events_by_month
  end

end
