require 'spec_helper'

describe EventMailer do
  fixtures :emails, :email_lists, :email_list_memberships, :events, :users
  it 'delivers to the right folks' do
    m = EventMailer.event_added(Event.first)
    EventMailerList.first.emails.each do |expected|
      m.to.should include expected.email
    end
    m.from.should include 'info@missionartistsunited.org'
  end
end
