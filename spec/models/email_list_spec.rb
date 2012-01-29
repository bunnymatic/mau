# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

class TestMailerList < EmailList; end
class WhateverMailList < EmailList; end

describe EmailList do
  fixtures :email_lists, :email_list_memberships, :emails
  describe 'adding elements' do
    ['this', 's p a c e d o u t', 'me at thatplace.com'].each do |email|
      it "does not allow #{email} because it\'s invalid" do
        eml = EmailList.new(:type => 'WhateverMailList')
        eml.emails << Email.new(:email => email)
        eml.should_not be_valid
      end
    end
    it "adds valid emails" do
      expect {  
        eml = WhateverMailList.new
        ['a@example.com', 'b@example.com'].each do |email|
          eml.emails << Email.new(:email => email)
        end
        eml.save
      }.to change(Email, :count).by(2)

    end
    it "adds ids on the email_list_membership table" do
      eml = WhateverMailList.new
      ['a@example.com', 'b@example.com'].each do |email|
        eml.emails << Email.new(:email => email)
      end
      eml.save
      EmailListMembership.all.map(&:id).uniq.count.should >= 2
    end
    it "does not add duplicate emails to a list" do
      lambda {
        eml = TestMailerList.new
        eml.emails << Email.new(:email => 'joe@example.com')
        eml.emails << Email.new(:email => 'joe@example.com')
        eml.save
      }.should raise_error ActiveRecord::StatementInvalid 
    end
    
  end
  it "adds a new email list" do
    expect {  
      eml = TestMailerList.new
      ['uniq1@example.com', 'more_uniq@example.com'].each do |email|
        eml.emails << Email.new(:email => email)
      end
      eml.save
    }.to change(EmailList, :count).by(1)
  end
  describe 'sti' do
    it 'admin mailer returns the admin folks' do
      AdminMailerList.all.map(&:emails).flatten.count.should == 2
    end
    it 'event mailer returns the event folks' do
      EventMailerList.all.map(&:emails).flatten.count.should == 3
    end
  end
end
