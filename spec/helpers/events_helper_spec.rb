require File.dirname(__FILE__) + "/../spec_helper"

describe EventsHelper do

  describe 'event_time' do
    it 'returns Sep 7 6:00p - 9:00p for event with same date as start and end' do
      ev = Event.new(:starttime => Time.utc(2011,9,7,18,0),
                     :endtime => Time.utc(2011,9,7,22,0))
      EventsHelper::event_time(ev).should == 'Wed Sep 7, 6:00p - 10:00p'
    end
    it 'returns Sep 7 6:00p - Sep 8 9:00p for event with different date as start and end' do
      ev = Event.new(:starttime => Time.utc(2011,9,7,18,0),
                     :endtime => Time.utc(2011,9,8,22,0))
      EventsHelper::event_time(ev).should == 'Wed Sep 7, 6:00p - Thu Sep 8, 10:00p'
    end
  end
      
end
