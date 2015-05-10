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
    render_views
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
          assigns(:all_lists)[listtype].emails.count.should eql ct
        end
        it "the lists are full of Email objects" do
          assigns(:all_lists)[listtype].emails.should be_a_kind_of Array
          assigns(:all_lists)[listtype].emails.first.should be_a_kind_of Email
        end
      end
      it 'renders the 2 lists, Feedback and Events' do
        assert_select '.email_lists ul.listtypes > li', :count => 3
        assert_select '.email_lists ul.listtypes > li', /Feedback/
        assert_select '.email_lists ul.listtypes > li', /Event/
        assert_select '.email_lists ul.listtypes > li', /Admins/
      end
      it 'renders add email forms for each list' do
        assert_select '.email_lists ul.listtypes form', :count => 3
      end
    end

  end
end
