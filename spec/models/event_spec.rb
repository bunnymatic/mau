require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

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
    :starttime => Time.now + 24.hours,
    :endtime => Time.now + 25.hours,
    :url => "MyString"
  }.merge(opts)
  Event.new(params)
end
    
describe Event do
  fixtures :events
  
  before do 
    # validate fixture data
    before_now = 0
    after_now = 0
    Event.all.each do |ev|
      if ev.starttime < Time.now
        before_now += 1
      else
        after_now += 1
      end
    end
    before_now.should >= 1
    after_now.should >= 1
  end

  describe 'named scopes' do
    it "future returns only events that are in the future" do
      Event.future.all.each do |u|
        u.starttime.should > Time.now
      end
    end
    it "past returns only events that are in the past" do
      Event.past.all.each do |u|
        u.starttime.should < Time.now
      end
    end 
  end
  describe 'creation' do
    it 'geocodes on create' do
      Event.any_instance.expects(:compute_geocode)
      ev = create_event
      ev.save
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
end
