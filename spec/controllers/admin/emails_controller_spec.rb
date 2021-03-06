require 'rails_helper'

describe Admin::EmailsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:feedback_email_list) { FactoryBot.create(:feedback_email_list) }
  let(:admin_email_list) { FactoryBot.create(:admin_email_list) }
  let(:email_attrs) { FactoryBot.attributes_for(:email) }
  let(:feedback_email_list) { FactoryBot.create(:feedback_email_list) }
  let(:admin_email_list) { FactoryBot.create(:admin_email_list) }
  let!(:lists) { [feedback_email_list, admin_email_list] }

  describe 'POST#create' do
    before do
      login_as admin
    end
    def make_request
      post :create, xhr: true, params: { email_list_id: feedback_email_list.id, email: email_attrs }
    end
    it 'returns 200 on success' do
      expect(response).to be_successful
    end
    it 'returns json' do
      make_request
      expect(response.content_type.to_s).to eql 'application/json; charset=utf-8'
      expect(JSON.parse(response.body)).to have_key('emails')
    end
    it 'adds a new email to the email list' do
      expect do
        make_request
      end.to change(Email, :count).by(1)
    end
  end

  describe 'POST#destroy' do
    def make_delete_request
      delete :destroy, xhr: true, params: { email_list_id: feedback_email_list.id, id: first_email.id }
    end

    let(:first_email) do
      email = FactoryBot.create(:email)
      FeedbackMailerList.first.update(emails: [email])
      email
    end
    before do
      login_as admin
    end
    it 'deletes entries from an email list' do
      first_email
      expect do
        make_delete_request
      end.to change(FeedbackMailerList.first.emails, :count).by(-1)
    end
    it 'does not delete the email from the email table' do
      first_email
      expect do
        make_delete_request
      end.to change(Email, :count).by(0)
    end

    it 'returns a message indicating who was removed' do
      make_delete_request
      expect(response.content_type).to eql 'application/json; charset=utf-8'
      expect(response).to be_successful
    end
  end
end
