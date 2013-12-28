require 'spec_helper'

describe EventMailerList do
  fixtures :email_lists, :emails, :email_list_memberships
  it 'returns the right count for AdminMailerList' do
    ems = EventMailerList.first.emails
    ems.count.should == 3
    [:event_coordinator1, :event_coordinator2, :admin1].each do |em|
      ems.should include emails(em)
    end

  end
end

