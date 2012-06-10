require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventSubscriber do
  fixtures :application_events, :event_subscribers
  
  it 'builds the correct url for an event with no data' do
    testurl = 'http://example.com/tester'
    FakeWeb.register_uri(:get, testurl + "?type=GenericEvent&message=a+bland+event", {:status => 200})
    ev = GenericEvent.new(:message => 'a bland event')
    subscriber = EventSubscriber.new(:url => testurl, :event_type => 'GenericEvent')
    subscriber.publish(ev)
  end

  it 'builds the correct url for an event with some data' do
    testurl = 'http://example.com/tester'
    ev = OpenStudiosSignupEvent.first
    # we match that data is in the url and starts with { because its json
    FakeWeb.register_uri(:get, Regexp.new( testurl + "\?.*data=%7B" ), {:status => 200})
    subscriber = EventSubscriber.new(:url => testurl, :event_type => 'OpenStudiosSignupEvent')
    subscriber.publish(ev)
  end
end
    
    
  
