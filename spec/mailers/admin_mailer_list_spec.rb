require 'spec_helper'

describe AdminMailerList do
  before do
    list = FactoryGirl.create(:admin_email_list, :with_member)
  end

  it 'returns the right count for AdminMailerList' do
    ems = AdminMailerList.all.first.emails
    ems.count.should == 1
  end
  it 'is unique by type' do
    lambda { AdminMailerList.create }.should raise_error(ActiveRecord::StatementInvalid)
  end
  it 'adds email to the Email table' do
    mailing_list = AdminMailerList.all.first
    expect {
      mailing_list.emails << Email.new(:email => 'whatever@dude.com')
      mailing_list.save
    }.to change(Email, :count).by(1)
  end
  it 'adds email to this list' do
    mailing_list = AdminMailerList.all.first
    mailing_list.emails << Email.new(:email => 'whatever@dude.com')
    mailing_list.save
    mailing_list.reload
    mailing_list.emails.count.should == 2
  end
  it 'does not add duplicate emails' do
    mailing_list = AdminMailerList.all.first
    lambda {
      mailing_list.emails << Email.new(:email => 'whatever@dude.com')
      mailing_list.emails << Email.new(:email => 'whatever@dude.com')
      mailing_list.save
    }.should raise_error(ActiveRecord::StatementInvalid)
  end

end

