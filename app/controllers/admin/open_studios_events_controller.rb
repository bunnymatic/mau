module Admin
  class OpenStudiosEventsController < AdminController

    before_filter :admin_required

    def index
      @os_events = OpenStudiosEvent.all
    end

  end
end
