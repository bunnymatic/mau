module EventsHelper

  def self.format_starttime( starttime )
    full_fmt = "%a %b %e, %l:%M%p"
    hr_fmt = "%l:%M%p"
    starttime.strftime(full_fmt)
  end
  
  def self.format_fulltime( t0, t1 )
    full_fmt = "%a %b %e, %l:%M%p"
    hr_fmt = "%l:%M%p"
    result = format_starttime(t0)
    if !t1
      return result
    end
    same_day = [:year, :yday].all?{|method| t0.send(method) == t1.send(method)}
    if same_day
      result << " - " + t1.strftime(hr_fmt)
    else
      result << " - " + t1.strftime(full_fmt)
    end
    result.gsub(/\s+/, ' ').gsub(/(AM|PM)/) { |m| m.downcase.first }
  end

  def self.start_time(event)
    format_starttime(event.starttime);
  end

  def self.event_time(event) 
    format_fulltime(event.starttime, event.endtime)
  end

  def self.reception_time(event) 
    event.reception_starttime.present? ? format_fulltime(event.reception_starttime, event.reception_endtime) :''
  end

  def self.for_mobile_list(ev)
    "<span class='starttime'>%s</span><span class='event_title'>%s</span>" % [EventsHelper::start_time(ev), ev.title]
  end


end
