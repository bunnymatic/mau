class TimeSlotComputer
  CLOCK_TIME_REGEX = /^\s?(\d{1,2})\s?:\s?(\d{1,2})\s?([ap]m)\s?/i.freeze

  attr_reader :date, :duration, :start_clock_time, :end_clock_time

  def initialize(date, start_clock_time, end_clock_time, duration_minutes = 60)
    # *_clock_time are strings like "11:00 PM" or "5:00 am"
    @duration = duration_minutes
    @date = date
    @start_clock_time = start_clock_time
    @end_clock_time = end_clock_time
  end

  def run
    return [] unless date && start_clock_time && end_clock_time

    start_time = build_date_time(date, start_clock_time)
    end_time = build_date_time(date, end_clock_time)
    current = start_time
    slots = []
    while current < end_time
      current_end = current + duration.minutes
      slots << format_slot(current, current_end)
      current = current_end
    end
    slots
  end

  private

  def format_slot(start, finish)
    "#{start.iso8601}/#{finish.iso8601}"
  end

  def convert_to_24hr_time(clock_time)
    matches = CLOCK_TIME_REGEX.match(clock_time).to_a
    return unless matches

    hour, minute, period = matches[1..3]
    hour = hour.to_i % 12
    minute = minute.to_i
    hour += 12 if period.casecmp('pm').zero?
    [hour, minute]
  end

  def build_date_time(date, clock_time)
    hour, minute = convert_to_24hr_time(clock_time)
    date.in_time_zone(Conf.event_time_zone).beginning_of_day + hour.hours + minute.minutes
  end
end
