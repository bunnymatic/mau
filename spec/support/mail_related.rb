module MailRelated
  def stub_mailer_email(mailer, email)
    letter = instance_double(ActionMailer::MessageDelivery,
                             deliver_later: true,
                             deliver_now: true)
    allow(mailer).to receive(email).and_return(letter)
  end

  def stub_signup_notification
    stub_mailer_email(ArtistMailer, :signup_notification)
  end

  def stub_mailchimp
    allow(Gibbon::Request).to receive(:new).and_return(double.as_null_object)
  end
end

RSpec.configure do |config|
  config.include MailRelated
end
