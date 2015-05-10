require 'spec_helper'

describe Admin::EmailsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:feedback_email_list) { FactoryGirl.create(:feedback_email_list) }
  let(:event_email_list) { FactoryGirl.create(:event_email_list) }
  let(:admin_email_list) { FactoryGirl.create(:admin_email_list) }
  let(:email_attrs) { FactoryGirl.attributes_for(:email) }
  let(:feedback_email_list) { FactoryGirl.create(:feedback_email_list) }
  let(:event_email_list) { FactoryGirl.create(:event_email_list) }
  let(:admin_email_list) { FactoryGirl.create(:admin_email_list) }
  let!(:lists) { [feedback_email_list, admin_email_list, event_email_list] }

  describe 'POST#create' do
    before do
      login_as admin
    end
    def make_request
      xhr :post, :create, :email_list_id => event_email_list.id, :email => email_attrs
    end      
    it 'returns 200 on success' do
      make_request
      expect(response).to be_success
    end
    it 'returns json' do
      make_request
      expect(response.content_type.to_s).to eql 'application/json'
    end

    it 'redirects to itself on success' do
      make_request
      expect(response).to redirect_to admin_email_lists_path
    end
    it 'adds a new email to the email list' do
      expect {
        make_request
      }.to change(Email,:count).by(1)
    end
    it 'adds a new email to the email list' do
      make_request
      AdminMailerList.first.emails.map(&:formatted).should include FactoryGirl.build(:email, email_attrs).formatted
    end
  end

  describe 'POST#destroy' do
    let(:first_email) do
      email = FactoryGirl.create(:email)
      EventMailerList.first.update_attributes(:emails => [ email ])
      email
    end
    before do
      login_as admin
    end
    it 'deletes entries from an email list' do
      first_email
      expect {
        xhr :delete, :destroy, :email_list_id => :event, :id => first_email.id
      }.to change(EventMailerList.first.emails, :count).by(-1);
    end
    it 'does not delete the email from the email table' do
      first_email
      expect {
        xhr :delete, :destroy, :email_list_id => :event, :id => first_email.id
      }.to change(Email, :count).by(0);
    end

    it 'returns a message indicating who was removed' do
      xhr :delete, :destroy, :email_list_id => :event, :id => first_email.id
      response.content_type.should eql Mime::Type.lookup("application/json")
      expect(response).to be_success
      JSON.parse(response.body)['messages'].should match "Successfully removed #{first_email.email} from Events"
    end

    it 'returns an error if the email id is missing when trying to delete' do
      xhr :delete, :destroy, :email_list_id => :event, :id => 10
      response.content_type.should eql Mime::Type.lookup("application/json")
      expect(response).to_not be_success
      JSON.parse(response.body)['messages'].should match "Email ID is missing"
    end

  end
  
end
