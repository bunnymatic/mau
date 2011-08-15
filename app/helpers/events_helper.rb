module EventsHelper
  def self.event_time(event) 
    t0 = event.starttime
    t1 = event.endtime
    full_fmt = "%a %b %e %l:%M%p"
    hr_fmt = "%l:%M%p"
    same_day = [:year, :yday].all?{|method| t0.send(method) == t1.send(method)}
    result = t0.strftime(full_fmt)
    if same_day
      result << " - " + t1.strftime(hr_fmt)
    else
      result << " - " + t1.strftime(full_fmt)
    end
    result.gsub(/\s+/, ' ').gsub(/(AM|PM)/) { |m| m.downcase.first }
  end
end
