module Admin
  class OpenStudiosEventsController < ::BaseAdminController

    before_filter :admin_required

    def index
      @os_events = OpenStudiosEventService.all.map{|osev| OpenStudiosEventPresenter.new(osev)}
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

    def edit
      @os_event = OpenStudiosEvent.find(params[:id])
    end

    def update
      @os_event = OpenStudiosEventService.find(params[:id])
      if OpenStudiosEventService.update(@os_event, open_studios_event_params)
        redirect_to admin_open_studios_events_path, flash: {notice: 'Successfully updated an Open Studios Event'}
      else
        render :edit
      end
    end

    def destroy
      @os_event = OpenStudiosEventService.find(params[:id])
      OpenStudiosEventService.destroy(@os_event)
      redirect_to admin_open_studios_events_path, notice: "The Event has been removed"
   end

    private
    def open_studios_event_params
      params.require(:open_studios_event).permit(:title, :start_date, :end_date, :key, :logo)
    end
  end
end
