# frozen_string_literal: true
require 'rails_helper'

describe MailChimpService do
  let(:user) { create :user }
  subject(:service) { MailChimpService.new(user) }

  before do
    allow(ArtistMailer).to receive(:signup_notification).and_return(double(UserMailer).as_null_object)
  end

  describe '#mailchimp_additional_data' do
    it 'remaps attributes for mailchimp' do
      expect(service.mailchimp_additional_data).to eql(                                                         'FNAME' => user.firstname,
                                                                                                                'LNAME' => user.lastname)
    end
  end

  describe '#subscribe_and_welcome' do
    let(:user) { create :artist }
    before do
      mock_members = double("MailchimpMembers")
      expect(mock_members).to receive(:create).with( body: {
                                                      email_address: user.email,
                                                      status: 'subscribed',
                                                      merge_fields: {
                                                        'FNAME' => user.firstname,
                                                        'LNAME' => user.lastname,
                                                      },
                                                      email_type: "html"
                                                    })

      mock_lists = double("MailchimpLists", members: mock_members)
      mock_mailchimp_client = double(Gibbon::Request, lists: mock_lists )
      allow( Gibbon::Request ).to receive(:new).and_return(mock_mailchimp_client)
      user
    end
    it "updates mailchimp_subscribed_at column" do
      service.subscribe_and_welcome
      expect(user.reload.mailchimp_subscribed_at).to be <= Time.zone.now.utc.to_date
    end
  end
end
