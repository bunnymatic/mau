require "spec_helper"

describe EventsHelper do
  fixtures :events
  describe 'event_time' do
    it 'returns Sep 7 6:00p - 9:00p for event with same date as start and end' do
      ev = Event.new(:starttime => Time.zone.parse('Sep 7, 2011 6:00pm'),
                     :endtime => Time.zone.parse('Sept 7, 2011 10:00pm'))
      EventsHelper::event_time(ev).should == 'Wed Sep 7, 6:00p - 10:00p'
    end
    it 'returns Sep 7 6:00p - Sep 8 9:00p for event with different date as start and end' do
      ev = Event.new(:starttime => Time.zone.parse('Sep 7, 2011 6:00pm'),
                     :endtime => Time.zone.parse('Sept 8, 2011 10:00pm'))
      EventsHelper::event_time(ev).should == 'Wed Sep 7, 6:00p - Thu Sep 8, 10:00p'
    end
  end
      
  describe '#for_mobile_list' do
    it 'returns the title and start date of the event' do
      nuevo_titulo = "<div>the title is here</div>"
      ev = Event.create(:starttime => Time.zone.parse('Feb  7, 2011 6:00pm'),
                        :endtime => Time.zone.parse('Sept 8, 2011 10:00pm'))
      ev.update_attribute(:title, nuevo_titulo)
      title = EventsHelper::for_mobile_list(ev);
      title.should == "<span class='starttime'>Mon Feb  7,  6:00PM</span><span class='event_title'>%s</span>" % nuevo_titulo
    end
  end

end
