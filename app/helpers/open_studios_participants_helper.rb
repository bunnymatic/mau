require_relative '../../lib/util/range_helpers'

module OpenStudiosParticipantsHelper
  def merge_timeslots(timeslots)
    RangeHelpers.merge_overlapping(timeslots.map do |ts|
                                     Range.new(*OpenStudiosParticipant.parse_time_slot(ts))
                                   end).map { |range| [range.begin, range.end] }
  end

  def display_time_slots(timeslots, compact: false)
    Time.use_zone(Conf.event_time_zone) do
      method = compact ? :_compact_display_time_slot : :_long_form_display_time_slot
      merge_timeslots(timeslots).map do |ts|
        send(method, *ts)
      end
    end
  end

  def display_time_slot(timeslot, compact: false)
    Time.use_zone(Conf.event_time_zone) do
      method = compact ? :_compact_display_time_slot : :_long_form_display_time_slot
      send(method, *OpenStudiosParticipant.parse_time_slot(timeslot))
    end
  end

  def split_email(email)
    %i[name domain].zip(email.split('@')).to_h
  end

  def _compact_display_time_slot(start_time, end_time)
    [
      start_time.in_time_zone(Conf.event_time_zone).to_fs(:os_day),
      ' ',
      start_time.in_time_zone(Conf.event_time_zone).strftime('%l').strip,
      '-',
      end_time.in_time_zone(Conf.event_time_zone).strftime('%l%P %Z').strip,
    ].join
  end

  def _long_form_display_time_slot(start_time, end_time)
    [
      start_time.in_time_zone(Conf.event_time_zone).to_fs(:date_month_first),
      start_time.in_time_zone(Conf.event_time_zone).to_fs(:time_only),
      ' -',
      end_time.in_time_zone(Conf.event_time_zone).to_fs(:time_with_zone),
    ].join
  end
end
