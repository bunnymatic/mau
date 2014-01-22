class EventDecorator < Draper::Decorator
  delegate_all

  def start_date
    parse_date(starttime)
  end

  def start_time
    parse_time(starttime)
  end

  def reception_start_date
    parse_date(reception_starttime)
  end

  def reception_start_time
    parse_time(reception_starttime)
  end

  def end_date
    parse_date(endtime)
  end

  def end_time
    parse_time(endtime)
  end

  def reception_end_date
    parse_date(reception_endtime)
  end

  def reception_end_time
    parse_time(reception_endtime)
  end

  private

  def parse_time(t)
    t.strftime("%H:%M %p") if t
  end

  def parse_date(t)
    t.strftime("%d %B, %Y") if t
  end

end
