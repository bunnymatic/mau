require 'rails_helper'

describe AdminMailer do

  before do
    list = FactoryGirl.create(:admin_email_list, :with_member)
  end

  context '#spammer' do
    it 'delivers to the right folks' do
      m = AdminMailer.spammer({:page => 'thispage', :body => 'spam here', :login => nil})
      AdminMailerList.first.emails.each do |expected|
        expect(m.to).to include expected.email
      end
      expect(m.from).to include 'info@missionartistsunited.org'
      expect(m.body).to include 'spam here'
    end
  end
end
