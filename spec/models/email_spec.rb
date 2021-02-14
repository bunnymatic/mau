require 'rails_helper'

describe Email do
  let(:email_list) { FactoryBot.create(:feedback_email_list) }

  context 'validations' do
    describe 'email' do
      ['this', 'that', 's pa c e d @ out.com', '@example.com'].each do |email|
        it "reports that '#{email}' is not valid" do
          expect(Email.new(email: email)).not_to be_valid
        end
      end
      ['jo@example.com', 'this_dude+1@super.duper.google.com'].each do |email|
        it "reports that '#{email}' is valid" do
          expect(Email.new(email: email)).to be_valid
        end
      end
    end
  end
end
