# frozen_string_literal: true

require 'rails_helper'

describe FeedbackMailerList do
  before do
    FactoryBot.create(:feedback_email_list, :with_member)
  end

  it 'returns the right count for AdminMailerList' do
    ems = FeedbackMailerList.first.emails
    expect(ems.count).to eq(1)
  end

  it 'is unique by type' do
    expect { FeedbackMailerList.create }.to raise_error(ActiveRecord::StatementInvalid)
  end

  it 'adds email to the Email table' do
    mailing_list = FeedbackMailerList.all.first
    expect do
      mailing_list.emails << Email.new(email: 'whatever@dude.com')
      mailing_list.save
    end.to change(Email, :count).by(1)
  end

  it 'adds email to this list' do
    mailing_list = FeedbackMailerList.all.first
    mailing_list.emails << Email.new(email: 'whatever@dude.com')
    mailing_list.save
    mailing_list.reload
    expect(mailing_list.emails.count).to eq(2)
  end
end
