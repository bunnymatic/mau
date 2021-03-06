require 'rails_helper'

describe FeedbackMailer do
  let(:fb) { FactoryBot.create(:feedback) }
  before do
    FactoryBot.create(:feedback_email_list, :with_member)
  end

  it 'sets up the right "to" addresses' do
    m = FeedbackMailer.feedback(fb)
    FeedbackMailerList.first.emails.each do |expected|
      expect(m.to).to include expected.email
    end
    expect(m.from).to include 'info@missionartists.org'
  end
end
