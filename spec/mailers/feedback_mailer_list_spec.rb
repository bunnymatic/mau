require 'spec_helper'

describe FeedbackMailerList do
  fixtures :email_lists, :emails, :email_list_memberships
  it 'returns the right count for AdminMailerList' do
    ems = FeedbackMailerList.first.emails
    ems.count.should == 2
    [:feedback_coordinator1,:admin1].each do |em|
      ems.should include emails(em)
    end

  end

  it 'is unique by type' do
    lambda { FeedbackMailerList.create }.should raise_error(ActiveRecord::StatementInvalid)
  end

  it 'adds email to the Email table' do
    mailing_list = FeedbackMailerList.all.first
    expect {
      mailing_list.emails << Email.new(:email => 'whatever@dude.com')
      mailing_list.save }.to change(Email, :count).by(1)
  end

  it 'adds email to this list' do
    mailing_list = FeedbackMailerList.all.first
    mailing_list.emails << Email.new(:email => 'whatever@dude.com')
    mailing_list.save
    mailing_list.reload
    mailing_list.emails.count.should == 3
  end

  describe 'formatted_emails' do
    it 'returns a string of comma separated recipients that are properly formatted' do
      ['fb1@example.com', 'me <admin1@example.com>'].each do |em|
        FeedbackMailerList.first.formatted_emails.should include em
      end
    end
  end

end
