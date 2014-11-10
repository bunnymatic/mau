require 'spec_helper'

describe AdminMailer do

  before do
    list = FactoryGirl.create(:admin_email_list, :with_member)
  end

  context '#spammer' do
    it 'delivers to the right folks' do
      m = AdminMailer.spammer({:page => 'thispage', :body => 'spam here', :login => nil})
      AdminMailerList.first.emails.each do |expected|
        m.to.should include expected.email
      end
      m.from.should include 'info@missionartistsunited.org'
      m.body.should include 'spam here'
    end
  end
end
