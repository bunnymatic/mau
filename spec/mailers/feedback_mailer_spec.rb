require 'spec_helper'

describe FeedbackMailer do
  fixtures :emails, :email_lists, :email_list_memberships, :feedbacks
  it 'sets up the right "to" addresses' do
    fb = feedbacks(:feedback1)
    m = FeedbackMailer.feedback(fb)
    FeedbackMailerList.first.emails.each do |expected|
      m.to.should include expected.email
    end
    m.from.should include 'info@missionartistsunited.org'
  end

  it 'does not actually deliver the email' do
    fb = feedbacks(:feedback1)
    m = FeedbackMailer.feedback(fb)
    expect(m).to_not receive(:old_deliver!)
    m.deliver!
  end

end
