# frozen_string_literal: true
module MailRelated
  def stub_signup_notification
    mailer_double = double('ArtistMailer::SignupNotificationEmail', deliver_later: true, deliver_now: true)
    allow(ArtistMailer).to receive(:signup_notification).and_return(mailer_double)
  end

  def stub_mailchimp
    allow(Gibbon::Request).to receive(:new).and_return(double.as_null_object)
  end
end

RSpec.configure do |config|
  config.include MailRelated
end
