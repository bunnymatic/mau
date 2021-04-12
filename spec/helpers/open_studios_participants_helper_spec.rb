require 'rails_helper'

describe OpenStudiosParticipantsHelper do
  describe '.display_time_slot' do
    def make_1hour_timeslot(t) # rubocop:disable Naming/MethodParameterName
      [t, t + 1.hour].map(&:to_i).join('::')
    end

    Time.use_zone(Conf.event_time_zone) do
      test_scenarios = [
        [Time.zone.local(2021, 1, 14, 16), '01/14/2021 4:00pm - 5:00pm PST'],
        [Time.zone.local(2021, 5, 6, 1), '05/06/2021 1:00am - 2:00am PDT'],
        [Time.zone.local(2021, 10, 12, 14), '10/12/2021 2:00pm - 3:00pm PDT'],
      ]
      test_scenarios.each do |scenario|
        it "returns long format #{scenario.last} for the date #{scenario.first}" do
          expect(helper.display_time_slot(make_1hour_timeslot(scenario.first))).to eq scenario.last
        end
      end
    end

    Time.use_zone(Conf.event_time_zone) do
      test_scenarios = [
        [Time.zone.local(2021, 1, 14, 16), 'Jan 14 4-5pm PST'],
        [Time.zone.local(2021, 5, 6, 1), 'May 6 1-2am PDT'],
        [Time.zone.local(2021, 10, 12, 14), 'Oct 12 2-3pm PDT'],
      ]
      test_scenarios.each do |scenario|
        it "returns short format #{scenario.last} for the date #{scenario.first} with compact: true" do
          expect(helper.display_time_slot(make_1hour_timeslot(scenario.first), compact: true)).to eq scenario.last
        end
      end
    end
  end

  describe '.display_time_slots' do
    def make_timeslots(t) # rubocop:disable Naming/MethodParameterName
      [
        [t, t + 1.hour].map(&:to_i).join('::'),
        [t + 1.hour, t + 3.hours].map(&:to_i).join('::'),
        [t + 1.day, t + 1.day + 1.hour].map(&:to_i).join('::'),
      ]
    end

    Time.use_zone(Conf.event_time_zone) do
      test_scenarios = [
        [Time.zone.local(2021, 1, 14, 16), ['01/14/2021 4:00pm - 7:00pm PST', '01/15/2021 4:00pm - 5:00pm PST']],
        [Time.zone.local(2021, 5, 6, 1), ['05/06/2021 1:00am - 4:00am PDT', '05/07/2021 1:00am - 2:00am PDT']],
        [Time.zone.local(2021, 10, 12, 14), ['10/12/2021 2:00pm - 5:00pm PDT', '10/13/2021 2:00pm - 3:00pm PDT']],
      ]
      test_scenarios.each do |scenario|
        it 'returns long format merged time slots' do
          time_slots = helper.display_time_slots(make_timeslots(scenario.first))
          scenario.last.each do |entry|
            expect(time_slots).to include entry
          end
        end
      end
    end

    Time.use_zone(Conf.event_time_zone) do
      test_scenarios = [
        [Time.zone.local(2021, 1, 14, 16), ['Jan 14 4-7pm PST', 'Jan 15 4-5pm PST']],
        [Time.zone.local(2021, 5, 6, 1), ['May 6 1-4am PDT', 'May 7 1-2am PDT']],
        [Time.zone.local(2021, 10, 12, 14), ['Oct 12 2-5pm PDT', 'Oct 13 2-3pm PDT']],
      ]
      test_scenarios.each do |scenario|
        it 'returns short format merged time slots with compact: true' do
          time_slots = helper.display_time_slots(make_timeslots(scenario.first), compact: true)
          scenario.last.each do |entry|
            expect(time_slots).to include entry
          end
        end
      end
    end
  end

  describe '.split_email' do
    it 'returns name and domain from email' do
      expect(helper.split_email('jon@whatever.com')).to eq({ name: 'jon', domain: 'whatever.com' })
      expect(helper.split_email('zzz+103@long.super.tld.example.com')).to eq({ name: 'zzz+103', domain: 'long.super.tld.example.com' })
    end
  end

  describe '.generate_collapsed_timeslots' do
    it 'returns collapsed time slots' do
      timeslots = ['1617598800::1617602400', '1617595200::1617598800']
      expect(helper.merge_timeslots(timeslots)).to eq([[Time.zone.parse('2021-04-05 04:00:00 UTC'), Time.zone.parse('2021-04-05 06:00:00 UTC')]])
    end
  end
end
