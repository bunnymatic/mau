module EventsHelper
  def self.event_time(event) 
    full_fmt = "%a %b %e %l:%M%p"
    hr_fmt = "%l:%M%p"
    t0 = event.starttime
    result = t0.strftime(full_fmt)
    if !event.endtime
      return result
    end
    t1 = event.endtime
    same_day = [:year, :yday].all?{|method| t0.send(method) == t1.send(method)}
    if same_day
      result << " - " + t1.strftime(hr_fmt)
    else
      result << " - " + t1.strftime(full_fmt)
    end
    result.gsub(/\s+/, ' ').gsub(/(AM|PM)/) { |m| m.downcase.first }
  end
end
