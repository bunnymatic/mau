require 'rails_helper'

describe FeedbackMailer do

  let(:fb) { FactoryGirl.create(:feedback) }
  before do
    list = FactoryGirl.create(:feedback_email_list, :with_member)
  end

  it 'sets up the right "to" addresses' do
    m = FeedbackMailer.feedback(fb)
    FeedbackMailerList.first.emails.each do |expected|
      expect(m.to).to include expected.email
    end
    expect(m.from).to include 'info@missionartistsunited.org'
  end

  it 'does not actually deliver the email' do
    m = FeedbackMailer.feedback(fb)
    expect(m).to_not receive(:old_deliver_now)
    m.deliver_now
  end

end
