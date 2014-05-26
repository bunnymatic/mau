require 'spec_helper'

describe EmailListsController do
  fixtures :email_lists, :emails, :email_list_memberships, :users, :roles_users, :roles
  [:index].each do |endpoint|
    describe 'not logged in' do
      describe endpoint do
        before do
          get endpoint
        end
        it_should_behave_like 'not authorized'
      end
    end
    describe 'logged in as plain user' do
      describe endpoint do
        before do
          login_as :maufan1
          get endpoint
        end
        it_should_behave_like 'not authorized'
      end
    end
    it "responds success if logged in as admin" do
      login_as :admin
      get endpoint
      expect(response).to be_success
    end
  end

  describe 'POST#add' do
    before do
      login_as :admin
    end
    let(:test_email) { 'mr_new@example.com' }
    let(:email_attrs) { {:name => 'new dude', :email => test_email } }
    let(:lookup_email) { Email.where(:email => test_email).first }

    it 'returns 200 on success' do
      xhr :post, :add, :listtype => :event, :email => email_attrs
      expect(response).to redirect_to email_lists_path
    end

    it 'redirects to itself on success' do
      xhr :post, :add, :listtype => :event, :email => email_attrs
      expect(response).to redirect_to email_lists_path
    end
    it 'adds a new email to the email list' do
      expect {
        xhr :post, :add,  :listtype => :event, :email => email_attrs
      }.to change(Email,:count).by(1)
    end
    it 'adds a new email to the email list' do
      xhr :post, :add, :listtype => :admin, :email => email_attrs
      AdminMailerList.first.emails.map(&:formatted).should include lookup_email.formatted
    end

    it 'redirects to itself with flash message when asking for an invalid list' do
      xhr :post, :add, :listtype => :bogus, :email => email_attrs
      flash[:error].should match /couldn't find that list/
      expect(response).to redirect_to email_lists_path
    end

  end

  describe 'POST#destroy' do
    let(:first_email) { EventMailerList.first.emails.first }
    before do
      login_as :admin
    end
    it 'deletes entries from an email list' do
      expect {
        xhr :delete, :destroy, :listtype => :event, :id => first_email.id
      }.to change(EventMailerList.first.emails, :count).by(-1);
    end
    it 'does not delete the email from the email table' do
      expect {
        xhr :delete, :destroy, :listtype => :event, :id => first_email.id
      }.to change(Email, :count).by(0);
    end

    it 'returns a message indicating who was removed' do
      xhr :delete, :destroy, :listtype => :event, :id => first_email.id
      response.content_type.should eql Mime::Type.lookup("application/json")
      expect(response).to be_success
      JSON.parse(response.body)['messages'].should match "Successfully removed #{first_email.email} from Events"
    end

    it 'returns an error if the email id is missing when trying to delete' do
      xhr :delete, :destroy, :listtype => :event, :id => 10
      response.content_type.should eql Mime::Type.lookup("application/json")
      expect(response).to_not be_success
      JSON.parse(response.body)['messages'].should match "Email ID is missing"
    end

  end

  describe '#index' do
    render_views
    before do
      login_as :admin
    end
    describe 'GET' do
      before do
        get :index
      end
      it_should_behave_like 'logged in as admin'
      it_should_behave_like 'returns success'
      [ [:feedback, 2, 'FeedbackMailerList'],
        [:event, 3, 'EventMailerList']].each do |listtype, ct, mailer|
        it "assigns #{ct} emails to the #{listtype} list" do
          assigns(:all_lists)[listtype].count.should eql ct
        end
        it "the lists are full of Email objects" do
          assigns(:all_lists)[listtype].should be_a_kind_of Array
          assigns(:all_lists)[listtype].first.should be_a_kind_of Email
        end
        it 'renders the list type in a hidden input' do
          assert_select ".email_lists ul.listtypes form input[name='listtype']" do |tg|
            tg.map{|t| t['type']}.uniq.should eql ['hidden']
          end
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
