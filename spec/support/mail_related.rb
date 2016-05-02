module MailRelated

  def stub_signup_notification
    allow(ArtistMailer).to receive(:signup_notification).and_return(double('ArtistMailer::SignupNotificationEmail', deliver_later: true, deliver_now: true))
  end

  def stub_mailchimp
    allow(Gibbon::Request).to receive(:new).and_return(double.as_null_object)
  end

end

RSpec.configure do |config|
  config.include MailRelated
end
