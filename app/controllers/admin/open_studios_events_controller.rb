module Admin
  class OpenStudiosEventsController < AdminController

    before_filter :admin_required

    def index
      @os_events = OpenStudiosEvent.all
    end

    def new
      @os_event = OpenStudiosEvent.new
    end

    def create
      @os_event = OpenStudiosEvent.new(open_studios_event_params)
      if @os_event.save
        redirect_to admin_open_studios_events_path, flash: {notice: 'Successfully added a new Open Studios Event'}
      else
        render :new
      end
    end

    private
    def open_studios_event_params
      params[:open_studios_event]
    end
  end
end
