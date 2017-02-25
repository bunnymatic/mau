# frozen_string_literal: true
require 'rails_helper'

describe Admin::EmailsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:feedback_email_list) { FactoryGirl.create(:feedback_email_list) }
  let(:admin_email_list) { FactoryGirl.create(:admin_email_list) }
  let(:email_attrs) { FactoryGirl.attributes_for(:email) }
  let(:feedback_email_list) { FactoryGirl.create(:feedback_email_list) }
  let(:admin_email_list) { FactoryGirl.create(:admin_email_list) }
  let!(:lists) { [feedback_email_list, admin_email_list] }

  describe 'POST#create' do
    before do
      login_as admin
    end
    def make_request
      post :create, xhr: true, params: { email_list_id: feedback_email_list.id, email: email_attrs }
    end
    it 'returns 200 on success' do
      make_request
      expect(response).to be_success
    end
    it 'returns json' do
      make_request
      expect(response.content_type.to_s).to eql 'application/json'
    end
    it 'adds a new email to the email list' do
      expect do
        make_request
      end.to change(Email,:count).by(1)
    end
  end

  describe 'POST#destroy' do
    def make_delete_request
      delete :destroy, xhr: true, params: { email_list_id: feedback_email_list.id, id: first_email.id }
    end

    let(:first_email) do
      email = FactoryGirl.create(:email)
      FeedbackMailerList.first.update_attributes(emails: [ email ])
      email
    end
    before do
      login_as admin
    end
    it 'deletes entries from an email list' do
      first_email
      expect do
        make_delete_request
      end.to change(FeedbackMailerList.first.emails, :count).by(-1);
    end
    it 'does not delete the email from the email table' do
      first_email
      expect do
        make_delete_request
      end.to change(Email, :count).by(0);
    end

    it 'returns a message indicating who was removed' do
      make_delete_request
      expect(response.content_type).to eql "application/json"
      expect(response).to be_success
    end
  end
end
