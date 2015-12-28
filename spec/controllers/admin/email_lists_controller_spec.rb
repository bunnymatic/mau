require 'spec_helper'

describe Admin::EmailListsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:fan) { FactoryGirl.create(:fan, :active) }

  let(:test_email) { 'mr_new@example.com' }

  let(:feedback_email_list) { FactoryGirl.create(:feedback_email_list) }
  let(:event_email_list) { FactoryGirl.create(:event_email_list) }
  let(:admin_email_list) { FactoryGirl.create(:admin_email_list) }
  let!(:lists) { [feedback_email_list, admin_email_list, event_email_list] }

  before do
    AdminMailerList.first.update_attributes(:emails => [ FactoryGirl.create(:email, :email => test_email) ])
  end

  describe 'not logged in' do
    describe '#index' do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end
  describe 'logged in as plain user' do
    describe '#index' do
      before do
        login_as fan
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end
  it "responds success if logged in as admin" do
    login_as admin
    get :index
    expect(response).to be_success
  end

  describe '#index' do
    before do
      login_as admin
    end
    describe 'GET' do
      before do
        emails = FactoryGirl.build_list(:email, 5)
        EventMailerList.first.update_attributes(:emails => emails.sample(2))
        AdminMailerList.first.update_attributes(:emails => emails.sample(2))
        FeedbackMailerList.first.update_attributes(:emails => emails.sample(2))

        get :index
      end
      [ [:feedback, 2, 'FeedbackMailerList'],
        [:event, 2, 'EventMailerList']].each do |listtype, ct, mailer|
        it "assigns #{ct} emails to the #{listtype} list" do
          expect(assigns(:all_lists)[listtype].emails.count).to eql ct
        end
        it "the lists are full of Email objects" do
          expect(assigns(:all_lists)[listtype].emails).to be_a_kind_of Array
          expect(assigns(:all_lists)[listtype].emails.first).to be_a_kind_of Email
        end
      end
    end
  end
end
