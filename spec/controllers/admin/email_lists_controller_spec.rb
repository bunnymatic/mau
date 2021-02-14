require 'rails_helper'

describe Admin::EmailListsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:fan) { FactoryBot.create(:fan, :active) }

  let(:test_email) { 'mr_new@example.com' }

  let!(:feedback_email_list) { FactoryBot.create(:feedback_email_list) }
  let!(:admin_email_list) { FactoryBot.create(:admin_email_list) }
  let!(:lists) { [feedback_email_list, admin_email_list] }

  before do
    AdminMailerList.first.update(emails: [FactoryBot.create(:email, email: test_email)])
  end

  describe 'not logged in' do
    describe '#index' do
      before do
        get :index
      end
      it_behaves_like 'not authorized'
    end
  end
  describe 'logged in as plain user' do
    describe '#index' do
      before do
        login_as fan
        get :index
      end
      it_behaves_like 'not authorized'
    end
  end
  it 'responds success if logged in as admin' do
    login_as admin
    get :index
    expect(response).to be_successful
  end

  describe '#index' do
    before do
      login_as admin
    end
    describe 'GET' do
      before do
        emails = FactoryBot.build_list(:email, 5)
        AdminMailerList.first.update(emails: emails.sample(2))
        FeedbackMailerList.first.update(emails: emails.sample(2))

        get :index
      end

      it 'assigns 2 emails to the FeedbackMailerList list' do
        expect(assigns(:all_lists)[:feedback].emails.count).to eql 2
      end

      it 'the feedback lists are full of Email objects' do
        expect(assigns(:all_lists)[:feedback].emails).to have_at_least(1).email
        expect(assigns(:all_lists)[:feedback].emails.first).to be_a_kind_of Email
      end

      it 'assigns 2 emails to the AdminMailerList list' do
        expect(assigns(:all_lists)[:admin].emails.count).to eql 2
      end

      it 'the admin lists are full of Email objects' do
        expect(assigns(:all_lists)[:admin].emails).to have_at_least(1).email
        expect(assigns(:all_lists)[:admin].emails.first).to be_a_kind_of Email
      end
    end
  end
end
