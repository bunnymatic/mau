module MailRelated

  def stub_signup_notification
    allow(ArtistMailer).to receive(:signup_notification).and_return(double('OutgoingEmail', "deliver_now" => true))
  end

  def mock_mailchimp_client
    double('MockMailchimpClient').tap do |mock|
      lists = double('MockMailchimpLists')
      allow(lists).to receive(:subscribe).and_return(true)
      allow(mock).to receive(:lists).and_return(lists)
    end
  end

  def stub_mailchimp
    allow(Gibbon::API).to receive(:new).and_return(mock_mailchimp_client)
  end

end

RSpec.configure do |config|
  config.include MailRelated
end
