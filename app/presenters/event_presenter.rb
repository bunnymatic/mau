class EventPresenter

  include TzHelper
  include MauUrlHelpers

  delegate :id, :url, :description, :reception_starttime, :reception_endtime, :starttime, :color, :name,
           :venue, :map_link, :address_hash, :endtime, :title, :start_at, :end_at, :clip_range,
           :published?, :in_progress?, :future?, :past?, :to => :event

  attr_accessor :event

  def initialize(view_context, event)
    @view_context = view_context
    @event = event
  end

  def month_year_key
    starttime.strftime('%Y%m')
  end

  def display_month
    @display_month ||= event.stime.strftime('%B %Y')
  end

  def address
    @address ||= address_hash[:full]
  end

  def edit_path
    @view_context.edit_event_path(event)
  end

  def show_path
    @view_context.event_path(event)
  end

  def publish_path
    @view_context.publish_event_path(event)
  end

  def unpublish_path
    @view_context.unpublish_event_path(event)
  end

  def delete_path
    @view_context.event_path(event)
  end

  def event_website_url
    @event_website_url ||=
      begin
        return url if /^https?:\.\./ =~ url
        add_http(url)
      end
  end

  def event_website_display
    event_website_url.gsub(/^https?:\/\//,'')
  end

  def link_to_event_website
    @view_context.link_to event_website_display, event_website_url
  end

  def link_to_clean_url(_url)
    display = _url.gsub(/^https?:\/\//, '')
    url = add_http(_url)
    link_to display, url
  end

  def event_classes
    @event_classes ||=
      ([published? ? 'published':'unpublished'] +
       %w(future in_progress past).select{|clz| self.send("#{clz}?") }).compact.uniq
  end

  def display_event_time
    @display_event_time ||= formatted_fulltime
  end

  def display_reception_time
    @display_event_time ||= formatted_reception_time
  end

  def for_mobile_list
    [@view_context.content_tag('span', simple_start_time, :class => 'starttime'),
     @view_context.content_tag('span', title, :class => 'title')].join
  end

  private

  DATE_TIME_FORMAT = "%a %b %e, %l:%M%p"
  TIME_FORMAT = "%l:%M%p"
  SHORT_DATE_FORMAT = "%Y-%m-%d"

  def simple_start_time
    in_mau_time(event.stime).strftime(SHORT_DATE_FORMAT)
  end

  def formatted_starttime
    @formatted_starttime = in_mau_time(starttime).strftime(DATE_TIME_FORMAT)
  end

  def formatted_reception_time
    @formatted_reception_starttime = in_mau_time(reception_starttime).strftime(DATE_TIME_FORMAT)
  end

  def in_one_day?(t0, t1)
    t0 && t1 && %w(year yday).all?{|method| t0.send(method) == t1.send(method)}
  end

  def formatted_reception_time
    @formatted_reception_time ||=
      begin
        formatted = [formatted_reception_time]
        if reception_endtime
          formatter = in_one_day?(reception_starttime, reception_endtime) ? TIME_FORMAT : DATE_TIME_FORMAT
          formatted << in_mau_time(reception_endtime).strftime(formatter)
        end
        formatted.join(" - ")
      end
  end

  def formatted_fulltime
    @formatted_fulltime ||=
      begin
        formatted = [formatted_starttime]
        if endtime
          formatter = in_one_day?(starttime, endtime) ? TIME_FORMAT : DATE_TIME_FORMAT
          formatted << in_mau_time(endtime).strftime(formatter)
        end
        formatted.join(" - ")
      end
  end

end
