require 'spec_helper'

describe FeedbackMailer do

  let(:fb) { FactoryGirl.create(:feedback) }
  before do
    list = FactoryGirl.create(:feedback_email_list, :with_member)
  end

  it 'sets up the right "to" addresses' do
    m = FeedbackMailer.feedback(fb)
    FeedbackMailerList.first.emails.each do |expected|
      m.to.should include expected.email
    end
    m.from.should include 'info@missionartistsunited.org'
  end

  it 'does not actually deliver the email' do
    m = FeedbackMailer.feedback(fb)
    expect(m).to_not receive(:old_deliver!)
    m.deliver!
  end

end
