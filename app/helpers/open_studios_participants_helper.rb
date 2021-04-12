module OpenStudiosParticipantsHelper
  def display_time_slot(timeslot, compact: false)
    Time.use_zone(Conf.event_time_zone) do
      method = compact ? :_compact_display_time_slot : :_long_form_display_time_slot
      send(method, timeslot)
    end
  end

  def split_email(email)
    %i[name domain].zip(email.split('@')).to_h
  end

  def _compact_display_time_slot(timeslot)
    start_time, end_time = OpenStudiosParticipant.parse_time_slot(timeslot)
    [
      start_time.in_time_zone(Conf.event_time_zone).to_s(:os_day),
      ' ',
      start_time.in_time_zone(Conf.event_time_zone).strftime('%l').strip,
      '-',
      end_time.in_time_zone(Conf.event_time_zone).strftime('%l%P %Z').strip,
    ].join
  end

  def _long_form_display_time_slot(timeslot)
    start_time, end_time = OpenStudiosParticipant.parse_time_slot(timeslot)
    [
      start_time.in_time_zone(Conf.event_time_zone).to_s(:date_month_first),
      start_time.in_time_zone(Conf.event_time_zone).to_s(:time_only),
      ' -',
      end_time.in_time_zone(Conf.event_time_zone).to_s(:time_with_zone),
    ].join
  end
end
