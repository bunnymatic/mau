class EventsPresenter

  include Enumerable

  delegate :empty?, :to => :events
  attr_accessor :events

  def initialize(view_context, events, year_month = nil)
    @view_context = view_context
    @events = events.map{|ev| EventPresenter.new(view_context, ev) }.sort_by{|ev| -ev.event.starttime.to_i}
    @year_month = year_month
  end

  def current
    @current ||= ((keyed_by_month.keys.include? @year_month) ? @year_month : nil)
  end

  def by_month
    @by_month ||= keyed_by_month
  end
    
  def each(&block)
    @events.each(&block)
  end

  private
  def keyed_by_month
    {}.tap do |by_month|
      @events.each do |ev|
        key = ev.month_year_key
        by_month[key] ||= {:display => ev.display_month, :events => [] }
        by_month[key][:events] << ev
      end
    end
  end

         
end
