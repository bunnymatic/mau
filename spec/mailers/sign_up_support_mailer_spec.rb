require 'rails_helper'

describe SignUpSupportMailer do
  let(:fb) { FactoryBot.create(:feedback) }

  subject(:email) { described_class.secret_word_request(fb) }

  context 'if the mailing list has been set up' do
    before do
      FactoryBot.create(:sign_up_support_email_list, :with_member)
    end

    it 'sets up the right "to" addresses' do
      SignUpSupportMailerList.first.emails.each do |expected|
        expect(email.to).to include expected.email
      end
      expect(email.from).to include 'info@missionartists.org'
    end

    it 'sets the right subject' do
      expect(email.subject).to eq "[Mission Artists Support] Someone's trying to sign up"
    end
  end

  context 'if the mailing list has not been set up' do
    it 'uses fallback to addresses' do
      expect(email.to).to match_array([
                                        'jon+mausignup@bunnymatic.com',
                                        'trish@trishtunney.com',
                                      ])
    end
  end
end
