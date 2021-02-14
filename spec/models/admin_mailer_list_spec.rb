require 'rails_helper'

describe AdminMailerList do
  before do
    FactoryBot.create(:admin_email_list, :with_member)
  end

  it 'returns the right count for AdminMailerList' do
    ems = AdminMailerList.all.first.emails
    expect(ems.count).to eq(1)
  end
  it 'is unique by type' do
    expect { AdminMailerList.create }.to raise_error(ActiveRecord::StatementInvalid)
  end
  it 'adds email to the Email table' do
    mailing_list = AdminMailerList.all.first
    expect do
      mailing_list.emails << Email.new(email: 'whatever@dude.com')
      mailing_list.save
    end.to change(Email, :count).by(1)
  end
  it 'adds email to this list' do
    mailing_list = AdminMailerList.all.first
    mailing_list.emails << Email.new(email: 'whatever@dude.com')
    mailing_list.save
    mailing_list.reload
    expect(mailing_list.emails.count).to eq(2)
  end
  it 'does not add duplicate emails' do
    mailing_list = AdminMailerList.all.first
    expect do
      mailing_list.emails << Email.new(email: 'whatever@dude.com')
      mailing_list.emails << Email.new(email: 'whatever@dude.com')
      mailing_list.save
    end.to raise_error(ActiveRecord::StatementInvalid)
  end
end
