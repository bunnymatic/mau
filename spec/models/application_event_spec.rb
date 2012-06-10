require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class EventWithNoSubscribersClass < ApplicationEvent; end    

describe ApplicationEvent do
  fixtures :application_events, :event_subscribers
  
  it 'serializes the data field' do
    ApplicationEvent.all.any?{|ae| ae.data}.should be_true, 'you need some application events with data in your fixtures'
    ApplicationEvent.all.select{|ae| ae.data}.each do |ae|
      ae.data.keys.should_not be_empty
    end
  end

  it 'functions as an STI table' do
    OpenStudiosSignupEvent.all.should eql ApplicationEvent.find_all_by_type('OpenStudiosSignupEvent')
  end

  it 'sends events to subscribers after save' do
    EventSubscriber.any_instance.expects(:publish)
    OpenStudiosSignupEvent.create(:message => 'this is a new open studios event')
  end
  it 'sends no events if there are no subscribers' do
    EventSubscriber.any_instance.expects(:publish).never
    EventWithNoSubscribersClass.create(:message => 'this is a stupid event')
  end

end
