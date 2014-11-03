require 'spec_helper'

describe FeedbackMailerList do
  before do
    list = FactoryGirl.create(:feedback_email_list, :with_member)
  end

  it 'returns the right count for AdminMailerList' do
    ems = FeedbackMailerList.first.emails
    ems.count.should == 1
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
    mailing_list.emails.count.should == 2
  end

end
