require 'rails_helper'

describe AdminMailer do
  before do
    FactoryBot.create(:admin_email_list, :with_member)
  end

  context '#spammer' do
    let(:email) { described_class.spammer(page: 'thispage', body: 'spam here', login: nil) }
    it 'sets the subject' do
      expect(email.subject).to start_with('[MAU Spammer][test] ')
    end
    it 'delivers to the right folks' do
      AdminMailerList.first.emails.each do |expected|
        expect(email.to).to include expected.email
      end
      expect(email.from).to include 'info@missionartists.org'
      expect(email).to have_body_text 'spam here'
    end
  end

  context '#server_trouble' do
    let(:status) do
      {
        version: Mau::Version::VERSION,
        main: true,
        elasticsearch: true,
      }
    end

    subject(:email) { described_class.server_trouble(status) }

    it 'sets the subject' do
      expect(email.subject).to eq('[MAU Admin][test] server trouble...')
    end

    it 'delivers to the right folks' do
      AdminMailerList.first.emails.each do |expected|
        expect(email.to).to include expected.email
      end
      expect(email.from).to include 'info@missionartists.org'
    end

    it 'includes the status info' do
      expect(email).to have_css 'pre code'
      expect(email).to have_body_text '"elasticsearch": true'
    end
  end
end
