module OpenStudiosParticipantsHelper
  def display_time_slot(timeslot)
    start_time, end_time = OpenStudiosParticipant.parse_time_slot(timeslot)
    "#{start_time.to_s(:admin_date_only)}: " \
      "#{start_time.in_time_zone(Conf.event_time_zone).to_s(:time_only)} - " +
      end_time.in_time_zone(Conf.event_time_zone).to_s(:time_with_zone).to_s
  end
end