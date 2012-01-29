require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe MauMailer do
  fixtures :email_lists, :email_list_memberships, :emails
  it 'provides an EmailList class to get recipients' do
    MauMailer.mailer_list.should == nil
  end
  [AdminMailer, EventMailer].each do |mailer|
    it "provides the correct list for #{mailer.name}" do
      mailer.mailer_list.should be Object.const_get(mailer.name + 'List')
    end
  end

  it 'the event mailer returns the right recipients' do
    emails = EventMailer.mailer_list.all.map(&:emails).flatten
    EventMailer.mailer_list.all.map(&:emails).flatten.count.should == 3
    emails.should include emails(:event_coordinator1)
    emails.should include emails(:event_coordinator2)
    emails.should include emails(:admin1)
  end

end
