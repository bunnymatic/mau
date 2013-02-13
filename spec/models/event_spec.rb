require 'spec_helper'

def create_event(opts = {}) 
  params = {
    :title => "MyString",
    :description => "MyText",
    :tweet => "MyString",
    :venue => "MyString",
    :street => "MyString",
    :city => "MyString",
    :state => "MyString",
    :zip => "MyString",
    :starttime => Time.zone.now + 24.hours,
    :endtime => Time.zone.now + 25.hours,
    :reception_starttime => Time.zone.now + 24.hours,
    :url => "MyString",
    :user_id => User.active.first.id
  }.merge(opts)
  Event.new(params)
end
    
describe Event do
  fixtures :events, :users
  
  before do 
    # validate fixture data
    before_now = 0
    after_now = 0
    Event.all.each do |ev|
      if ev.starttime < Time.zone.now
        before_now += 1
      else
        after_now += 1
      end
    end
    before_now.should >= 1
    after_now.should >= 1
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
      Event.all.map(&:id).should == Event.all.sort_by(&:starttime).map(&:id)
    end
    it 'not_past returns events that are not yet over' do
      Event.not_past.should == Event.all - Event.past
    end
  end

  describe 'validation' do
    it 'is an invalid event if end date is present and before start date' do
      ev = create_event
      ev.endtime = ev.starttime - 10.days
      ev.should_not be_valid
      ev.errors['endtime'].should be
    end
    it 'is an invalid event if reception endtime is present and before the reception start date' do
      ev = create_event
      ev.reception_endtime = ev.reception_starttime - 10.days
      ev.should_not be_valid
      ev.errors['reception_endtime'].should be
    end
  end
  describe 'creation' do
    it 'geocodes on create' do
      Event.any_instance.expects(:compute_geocode)
      ev = create_event
      ev.save
    end
    it 'stores the user association' do
      ev = create_event
      ev.save
      ev.reload
      ev.user.should == User.active.first
    end
      
  end
  describe 'updating' do
    it 'geocodes on update' do
      Event.any_instance.expects(:compute_geocode)
      ev = events(:future)
      ev.description = 'blah'
      ev.save
    end
  end
  
  describe '#future?' do
    it 'returns true for events in the future' do
      events(:future).future?.should be_true
    end
    it 'returns false for events in the past' do
      events(:past).future?.should be_false
    end
    it 'returns false for events in progress' do
      events(:in_progress).future?.should be_false
    end
  end
  describe '#in_progress?' do
    it 'returns true for events that are in progress' do
      events(:in_progress).in_progress?.should be_true
    end
    it 'returns false for events in the past' do
      events(:past).in_progress?.should be_false
    end
    it 'returns false for events in the future' do
      events(:future).in_progress?.should be_false
    end
  end
  describe '#past?' do
    it 'returns true for events in the past' do
      events(:past).past?.should be_true
    end
    it 'returns false for events that are in progress' do
      events(:in_progress).past?.should be_false
    end
    it 'returns true for events in the future' do
      events(:future).past?.should be_false
    end
  end
end
