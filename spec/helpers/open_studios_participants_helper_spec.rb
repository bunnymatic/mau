require 'rails_helper'

describe OpenStudiosParticipantsHelper do
  describe '.display_time_slot' do
    def make_1hour_timeslot(t) # rubocop:disable Naming/MethodParameterName
      [t, t + 1.hour].map(&:to_i).join('::')
    end

    Time.use_zone(Conf.event_time_zone) do
      test_scenarios = [
        [Time.zone.local(2021, 5, 6, 1), '05/06/2021 1:00am - 2:00am PDT'],
        [Time.zone.local(2021, 10, 12, 14), '10/12/2021 2:00pm - 3:00pm PDT'],
      ]
      test_scenarios.each do |scenario|
        it "returns #{scenario.last} for the date #{scenario.first}" do
          expect(helper.display_time_slot(make_1hour_timeslot(scenario.first))).to eq scenario.last
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
end
