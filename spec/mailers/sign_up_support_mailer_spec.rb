require 'rails_helper'

describe SignUpSupportMailer do
  let(:fb) { FactoryBot.create(:feedback) }
  before do
    FactoryBot.create(:sign_up_support_email_list, :with_member)
  end

  subject(:email) { described_class.secret_word_request(fb) }
  it 'sets up the right "to" addresses' do
    SignUpSupportMailerList.first.emails.each do |expected|
      expect(email.to).to include expected.email
    end
    expect(email.from).to include 'info@missionartists.org'
  end

  it 'sets the rigth subject' do
    expect(email.subject).to eq "[Mission Artists Support] Someone's trying to sign up"
  end
end
