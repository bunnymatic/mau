require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe EventMailer do
  fixtures :emails, :email_lists, :email_list_memberships, :events
  it 'delivers to the right folks' do
    m = EventMailer.create_event_added(Event.first)
    EventMailerList.first.emails.each do |expected|
      m.to.should include expected.email
    end
    m.from.should include 'noreply@missionartistsunited.org'
  end
end
