require 'spec_helper'

describe AdminMailer do
  fixtures :emails, :email_lists, :email_list_memberships, :events
  it 'delivers to the right folks' do
    m = AdminMailer.create_spammer({:page => 'thispage', :body => 'spam here', :login => nil})
    AdminMailerList.first.emails.each do |expected|
      m.to.should include expected.email
    end
    m.from.should include 'info@missionartistsunited.org'
    m.body.should include 'spam here'
  end
end
