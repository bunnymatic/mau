class EventSubscribersController < ApplicationController

  before_filter :admin_required
  layout 'mau-admin'

  def index
    @event_classes = ApplicationEvent.send(:subclasses).map(&:name)
    @subscribers = EventSubscriber.all
  end
end
