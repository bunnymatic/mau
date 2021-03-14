require 'rails_helper'

describe OpenStudiosEvent do
  let(:past_oses) do
    [
      FactoryBot.create(:open_studios_event, start_date: 6.months.ago),
      FactoryBot.create(:open_studios_event, start_date: 12.months.ago),
    ]
  end
  let(:current_os) do
    FactoryBot.create(:open_studios_event,
                      start_date: Time.zone.today.at_beginning_of_month.next_month)
  end
  let(:future_oses) do
    [
      FactoryBot.create(:open_studios_event, start_date: 6.months.since),
      FactoryBot.create(:open_studios_event, start_date: 12.months.since),
    ]
  end

  describe 'validations' do
    it 'requires dates to be in order' do
      os = build(:open_studios_event,
                 start_date: Time.zone.today,
                 end_date: Time.zone.yesterday)
      expect(os).not_to be_valid
      expect(os.errors[:end_date]).to include 'should be after start date'
    end

    it 'requires special event dates to be in order' do
      os = build(:open_studios_event,
                 start_date: Time.zone.today,
                 end_date: Time.zone.today + 1.week,
                 special_event_start_date: Time.zone.today + 2.days,
                 special_event_end_date: Time.zone.today + 1.day)

      expect(os).not_to be_valid
      expect(os.errors[:special_event_end_date]).to include 'should be after start date'
    end

    it 'is invalid if special event start date is defined and end date is not' do
      os = build(:open_studios_event,
                 start_date: Time.zone.today,
                 end_date: Time.zone.today + 1.week,
                 special_event_end_date: nil,
                 special_event_start_date: Time.zone.yesterday)

      expect(os).not_to be_valid
      expect(os.errors[:special_event_end_date]).to include 'must be present if special event start date is present'
    end

    it 'is invalid if special event end date is defined and start date is not' do
      os = build(:open_studios_event,
                 start_date: Time.zone.today,
                 end_date: Time.zone.today + 1.week,
                 special_event_start_date: nil,
                 special_event_end_date: Time.zone.yesterday)

      expect(os).not_to be_valid
      expect(os.errors[:special_event_start_date]).to include 'must be present if special event end date is present'
    end

    it 'requires special event dates to within event dates' do
      os = build(:open_studios_event,
                 start_date: Time.zone.today,
                 end_date: Time.zone.today + 1.week,
                 special_event_start_date: Time.zone.yesterday,
                 special_event_end_date: Time.zone.today + 9.days)

      expect(os).not_to be_valid
      expect(os.errors[:special_event_start_date]).to include 'must be during the main event dates'
      expect(os.errors[:special_event_start_date]).to include 'must be during the main event dates'
    end

    it 'special events can be the same as the main events' do
      now = Time.zone.today
      later = now + 1.day
      os = build(:open_studios_event,
                 start_date: now,
                 end_date: later,
                 special_event_start_date: now,
                 special_event_end_date: later)
      expect(os).to be_valid
    end
  end

  describe 'lifecycle' do
    describe 'before_save' do
      it 'generates time slots if special event fields have changed' do
        now = Time.zone.today
        later = now + 1.day
        os = build(:open_studios_event,
                   start_date: now,
                   end_date: later,
                   special_event_start_date: now,
                   special_event_end_date: later,
                   special_event_start_time: '11:00 am',
                   special_event_end_time: '2:00 pm')
        os.save
        os.reload
        expect(os.special_event_time_slots).to have(6).slots
      end

      it 'adds time slots even if they cross a month boundary' do
        freeze_time do
          travel_to(Time.zone.local(2020, 2, 27).in_time_zone(Conf.event_time_zone))
          now = Time.zone.today
          later = now + 3.days
          os = build(:open_studios_event,
                     start_date: now,
                     end_date: later,
                     special_event_start_date: now,
                     special_event_end_date: later,
                     special_event_start_time: '10:00 pm',
                     special_event_end_time: '11:00 pm')
          os.save
          os.reload
          expect(os.special_event_time_slots).to have(4).slots
        end
      end

      it 'removes time slots if we delete start/end dates from special event data' do
        os = create(:open_studios_event, :with_special_event)
        expect(os.special_event_time_slots).to have_at_least(1).slot
        os.special_event_start_date = nil
        os.special_event_end_date = nil
        os.save!
        os.reload
        expect(os.special_event_time_slots).to eq []
      end

      it 'removes time slots if we delete end time from special event data' do
        os = create(:open_studios_event, :with_special_event)
        expect(os.special_event_time_slots).to have_at_least(1).slot
        os.special_event_end_time = nil
        os.save!
        os.reload
        expect(os.special_event_time_slots).to eq []
      end
    end
  end

  describe 'scopes' do
    before do
      freeze_time
      [past_oses, current_os, future_oses].flatten
    end

    describe '#future' do
      it 'includes 2 open studios' do
        expect(OpenStudiosEvent.future.size).to eq(3)
      end
    end

    describe '#past' do
      it 'includes 1 open studios' do
        expect(OpenStudiosEvent.past.size).to eq(2)
      end
    end

    describe '#current' do
      it 'includes the nearest future event' do
        expect(OpenStudiosEvent.current).to eql current_os
      end

      it 'shows the first future event if today is monday after the last event' do
        travel_to(current_os.end_date + 1.day)

        expect(OpenStudiosEvent.current).to eql future_oses.first
      end
    end

    describe '#for_display' do
      it 'returns the pretty version for the current os' do
        expect(current_os.for_display).to eql current_os.start_date.strftime('%Y %b')
      end

      context 'with reverse true' do
        context 'if the dates are within the same month' do
          it 'returns the pretty version for the current os' do
            expected = current_os.start_date.strftime('%b %-d-') + current_os.end_date.strftime('%-d %Y')
            expect(current_os.for_display(reverse: true)).to eql expected
          end
        end
        context 'if the dates are across months' do
          let(:current_os) do
            date = 1.month.since.beginning_of_month
            date -= 1.day
            FactoryBot.create(:open_studios_event, start_date: date)
          end
          it 'returns the pretty version for the current os' do
            expected = current_os.start_date.strftime('%b %-d-') +
                       current_os.end_date.strftime('%b %-d %Y')
            expect(current_os.for_display(reverse: true)).to eql expected
          end
        end
      end
    end
  end

  describe '.key' do
    it 'returns a year month key based on start date' do
      expect(current_os.key).to eql current_os.start_date.year.to_s + sprintf('%02d', current_os.start_date.month)
    end
  end
end
