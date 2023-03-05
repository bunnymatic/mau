require 'rails_helper'

class TestMailerList < EmailList; end

class WhateverMailList < EmailList; end

describe EmailList do
  describe 'adding elements' do
    ['this', 's p a c e d o u t', 'me at thatplace.com'].each do |email|
      it "does not allow #{email} because it's invalid" do
        eml = EmailList.new(type: 'WhateverMailList')
        eml.emails << Email.new(email: email)
        expect(eml).not_to be_valid
      end
    end
    it 'adds valid emails' do
      expect do
        eml = WhateverMailList.new
        ['a@example.com', 'b@example.com'].each do |email|
          eml.emails << Email.new(email: email)
        end
        eml.save
      end.to change(Email, :count).by(2)
    end
    it 'adds ids on the email_list_membership table' do
      eml = WhateverMailList.new
      ['a@example.com', 'b@example.com'].each do |email|
        eml.emails << Email.new(email: email)
      end
      eml.save
      expect(EmailListMembership.all.map(&:id).uniq.count).to be >= 2
    end
    it 'does not add duplicate emails to a list' do
      expect do
        eml = TestMailerList.new
        eml.emails << Email.new(email: 'joe@example.com')
        eml.emails << Email.new(email: 'joe@example.com')
        eml.save
      end.to raise_error ActiveRecord::StatementInvalid
    end
  end
  it 'adds a new email list' do
    expect do
      eml = TestMailerList.new
      ['uniq1@example.com', 'more_uniq@example.com'].each do |email|
        eml.emails << Email.new(email: email)
      end
      eml.save
    end.to change(EmailList, :count).by(1)
  end
end
