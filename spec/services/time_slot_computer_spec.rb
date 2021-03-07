require 'rails_helper'

describe TimeSlotComputer do
  it 'computes timeslots for a date and time range' do
    freeze_time do
      travel_to Time.zone.local(2020, 11, 24, 5, 4, 44)
      date = Time.current
      start_time = '11:00 AM'
      end_time = ' 2:00pm '
      slots = TimeSlotComputer.new(date, start_time, end_time).run

      expected = [
        '2020-11-23T11:00:00-08:00/2020-11-23T12:00:00-08:00',
        '2020-11-23T12:00:00-08:00/2020-11-23T13:00:00-08:00',
        '2020-11-23T13:00:00-08:00/2020-11-23T14:00:00-08:00',
      ]
      expect(slots).to eq expected
    end
  end

  it 'returns nothing if the time spans midnight' do
    freeze_time do
      travel_to Time.zone.local(2020, 11, 24, 5, 4, 44)
      date = Time.current
      start_time = '11:30 PM'
      end_time = ' 12:30 AM'
      slots = TimeSlotComputer.new(date, start_time, end_time).run

      expect(slots).to eq []
    end
  end
end
