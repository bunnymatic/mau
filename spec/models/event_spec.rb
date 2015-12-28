require 'spec_helper'

describe Event do
  let(:future_event) { FactoryGirl.create(:event, starttime: Time.zone.now + 1.day, endtime: Time.zone.now + 2.days) }
  let(:in_progress_event) { FactoryGirl.create(:event, starttime: Time.zone.now - 1.hour, endtime: Time.zone.now + 1.hour) }
  let(:past_event) { FactoryGirl.create(:event, starttime: Time.zone.now - 2.days, endtime: Time.zone.now - 1.day) }

  before do
    fix_leaky_fixtures
    future_event
    past_event
  end

  describe 'named scopes' do
    it "future returns only events whose end time is the future" do
      expect(Event.future.all?{|u| u.future?}).to eq(true)
    end
    it "past returns only events that are in the past" do
      expect(Event.past.all?{|u| (u.endtime && u.endtime < Time.zone.now) || (u.starttime < Time.zone.now)}).to be
    end
    it 'published only returns events whose publish flag has been set true' do
      expect(Event.published.all{|u| u.publish}).to be
    end
    it 'returns events in order of starttime by default' do
      expect(Event.by_starttime.map(&:starttime)).to be_monotonically_increasing
    end
    it 'not_past returns events that are not yet over' do
      expect(Event.not_past.all).to eql Event.all - Event.past
    end
  end

  describe 'validation' do
    it 'is an invalid event if end date is present and before start date' do
      ev = FactoryGirl.build(:event)
      ev.endtime = ev.starttime - 10.days
      expect(ev).not_to be_valid
      expect(ev.errors['endtime']).to be
    end
    it 'is an invalid event if reception endtime is present and before the reception start date' do
      ev = FactoryGirl.build(:event, :with_reception)
      ev.reception_endtime = ev.reception_starttime - 10.days
      expect(ev).not_to be_valid
      expect(ev.errors['reception_endtime']).to be
    end
  end

  describe 'creation' do
    let(:user) { FactoryGirl.create(:artist, :active)}
    it 'stores the user association' do
      FactoryGirl.create(:event, :user => user)
      expect(Event.where(:user_id => User.active.first.id)).to be_present
    end
  end

  describe 'updating' do
  end

  describe '#future?' do
    it 'returns true for events in the future' do
      expect(future_event.future?).to eq(true)
    end
    it 'returns false for events in the past' do
      expect(past_event.future?).to eq false
    end
    it 'returns false for events in progress' do
      expect(in_progress_event.future?).to eq false
    end
  end
  describe '#in_progress?' do
    it 'returns true for events that are in progress' do
      expect(in_progress_event.in_progress?).to eq(true)
    end
    it 'returns false for events in the past' do
     expect(past_event.in_progress?).to eq false
    end
    it 'returns false for events in the future' do
      expect(future_event.in_progress?).to eq false
    end
  end
  describe '#past?' do
    it 'returns true for events in the past' do
      expect(past_event.past?).to eq(true)
    end
    it 'returns false for events that are in progress' do
      expect(in_progress_event.past?).to eq false
    end
    it 'returns true for events in the future' do
      expect(future_event.past?).to eq false
    end
  end
end
