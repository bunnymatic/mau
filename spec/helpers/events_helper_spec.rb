require File.dirname(__FILE__) + "/../spec_helper"

describe EventsHelper do
  fixtures :events
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
      
  describe '#for_mobile_list' do
    it 'returns the title and start date of the event' do
      nuevo_titulo = "<div>the title is here</div>"
      Event.first.update_attribute(:title, nuevo_titulo)
      title = EventsHelper::for_mobile_list(Event.first);
      title.should == "<span class='starttime'>Tue Feb  8,  9:16PM</span><span class='event_title'>%s</span>" % nuevo_titulo
    end
  end

end
