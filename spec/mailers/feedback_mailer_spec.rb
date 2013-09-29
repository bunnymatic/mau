require 'spec_helper'

describe FeedbackMailer do
  fixtures :emails, :email_lists, :email_list_memberships, :feedbacks
  it 'delivers to the right folks' do
    fb = feedbacks(:feedback1)
    m = FeedbackMailer.feedback(fb)
    FeedbackMailerList.first.emails.each do |expected|
      m.to.should include expected.email
    end
    m.from.should include 'info@missionartistsunited.org'
  end
end
