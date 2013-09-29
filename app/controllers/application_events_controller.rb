class ApplicationEventsController < ApplicationController

  before_filter :admin_required
  layout 'mau-admin'

  def index
    @events_by_type = ApplicationEvent.all.inject({}) do |result, item|
      tp = item.class.name
      result[tp] = [] unless result.has_key? tp
      result[tp] << item
      result
    end
  end
end
