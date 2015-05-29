module Admin
  class EventsController < BaseAdminController

    before_filter :editor_required

    def index
      @events = Event.all.map{|ev| EventPresenter.new(view_context, ev) }
    end

    def publish
      @event = Event.find(params[:id])
      @event.publish!
      flash[:notice] = "#{@event.title} has been successfully published."
      if (@event.user && @event.user.email)
        EventMailer.event_published(@event).deliver!
        flash[:notice] << " And we sent a notification email to #{@event.user.full_name} at #{@event.user.email}."
      end

      redirect_to admin_events_path
    end

    def unpublish
      @event = Event.find(params[:id])
      @event.unpublish!
      flash[:notice] = "#{@event.title} has been successfully unpublished."
      redirect_to admin_events_path
    end

  end
end

