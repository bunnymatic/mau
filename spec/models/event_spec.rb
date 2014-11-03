require 'spec_helper'

describe Event do
  let(:future_event) { FactoryGirl.create(:event, starttime: Time.zone.now + 1.day, endtime: Time.zone.now + 2.days) }
  let(:in_progress_event) { FactoryGirl.create(:event, starttime: Time.zone.now - 1.hour, endtime: Time.zone.now + 1.hour) }
  let(:past_event) { FactoryGirl.create(:event, starttime: Time.zone.now - 2.days, endtime: Time.zone.now - 1.day) }

  before do
    future_event
    past_event
  end

  describe 'named scopes' do
    it "future returns only events whose end time is the future" do
      Event.future.all?{|u| u.future?}.should be_true
    end
    it "past returns only events that are in the past" do
      Event.past.all?{|u| (u.endtime && u.endtime < Time.zone.now) || (u.starttime < Time.zone.now)}.should be
    end
    it 'published only returns events whose publish flag has been set true' do
      Event.published.all{|u| u.publish}.should be
    end
    it 'returns events in order of starttime by default' do
      Event.by_starttime.map(&:starttime).should be_monotonically_increasing
    end
    it 'not_past returns events that are not yet over' do
      (Event.not_past.all).should eql Event.all - Event.past
    end
  end

  describe 'validation' do
    it 'is an invalid event if end date is present and before start date' do
      ev = FactoryGirl.build(:event)
      ev.endtime = ev.starttime - 10.days
      ev.should_not be_valid
      ev.errors['endtime'].should be
    end
    it 'is an invalid event if reception endtime is present and before the reception start date' do
      ev = FactoryGirl.build(:event, :with_reception)
      ev.reception_endtime = ev.reception_starttime - 10.days
      ev.should_not be_valid
      ev.errors['reception_endtime'].should be
    end
  end

  describe 'creation' do
    let(:user) { FactoryGirl.create(:artist, :active)}
    it 'stores the user association' do
      FactoryGirl.create(:event, :user => user)
      Event.where(:user_id => User.active.first.id).should be_present
    end
  end

  describe 'updating' do
  end

  describe '#future?' do
    it 'returns true for events in the future' do
      future_event.future?.should be_true
    end
    it 'returns false for events in the past' do
      past_event.future?.should be_false
    end
    it 'returns false for events in progress' do
      in_progress_event.future?.should be_false
    end
  end
  describe '#in_progress?' do
    it 'returns true for events that are in progress' do
      in_progress_event.in_progress?.should be_true
    end
    it 'returns false for events in the past' do
     past_event.in_progress?.should be_false
    end
    it 'returns false for events in the future' do
      future_event.in_progress?.should be_false
    end
  end
  describe '#past?' do
    it 'returns true for events in the past' do
      past_event.past?.should be_true
    end
    it 'returns false for events that are in progress' do
      in_progress_event.past?.should be_false
    end
    it 'returns true for events in the future' do
      future_event.past?.should be_false
    end
  end
end
