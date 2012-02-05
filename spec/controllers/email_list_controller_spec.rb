require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe EmailListController do
  fixtures :email_lists, :emails, :email_list_memberships, :users
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
          login_as(users(:maufan1))
          get endpoint
        end
        it_should_behave_like 'not authorized'
      end
    end
    it "responds success if logged in as admin" do
      login_as(:admin)
      get endpoint
      response.should be_success
    end
  end
  
  describe '#index' do
    integrate_views
    before do
      login_as(:admin)
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
          assigns(:all_lists)[listtype].count.should == ct
        end
        it "the lists are full of Email objects" do
          assigns(:all_lists)[listtype].should be_a_kind_of Array
          assigns(:all_lists)[listtype].first.should be_a_kind_of Email
        end
        it 'renders the list type in a hidden input' do
          assert_select ".email_lists ul.listtypes form input[name='listtype']" do |tg|
            tg.map{|t| t['type']}.uniq.should == ['hidden']
          end
            
        end
      end
      it 'renders the 2 lists, Feedback and Events' do
        assert_select '.email_lists ul.listtypes > li', :count => 2
        assert_select '.email_lists ul.listtypes > li', /Feedback/
        assert_select '.email_lists ul.listtypes > li', /Event/
      end
      it 'renders add email forms for each list' do
        assert_select '.email_lists ul.listtypes form', :count => 2
      end
    end
    describe 'POST' do
      context 'xhr' do
        it 'redirects to itself with flash message when there is an error' do
          xhr :post, :index, :listtype => :event, :email => {:name => 'new dude', :email => 'mr_new@example.com'}
          response.content_type.should == 'application/json'
          response.code.should == '400'
          JSON.parse(response.body)['messages'].should match /not have all the required/
        end
        it 'returns 200 on success' do
          new_email = 'mr_ew@ex.com'
          xhr :post, :index, :method => 'add_email', :listtype => :event, :email => {:name => 'new dude', :email => new_email}
          response.content_type.should == 'application/json'
          response.should be_success
          JSON.parse(response.body)['messages'].should match "Successfully added #{new_email} to Events"
        end
        it 'returns an error if the email id is missing when trying to delete' do
          em = EventMailerList.first.emails.first
          xhr :post, :index, :method => 'remove_email', :listtype => :event, :email => {:name => 'jo'}
          response.content_type.should == 'application/json'
          response.should_not be_success
          JSON.parse(response.body)['messages'].should match "Email ID is missing"
        end
        it 'deletes entries from an email list' do
          em = EventMailerList.first.emails.first
          expect {
            xhr :post, :index, :method => 'remove_email', :listtype => :event, :email => {:id => em.id}
          }.to change(EventMailerList.first.emails, :count).by(-1);
        end
        it 'does not delete the email from the email table' do
          em = EventMailerList.first.emails.first
          expect {
            xhr :post, :index, :method => 'remove_email', :listtype => :event, :email => {:id => em.id}
          }.to change(Email, :count).by(0);
        end

        it 'returns a message indicating who was removed' do
          em = EventMailerList.first.emails.first
          xhr :post, :index, :method => 'remove_email', :listtype => :event, :email => {:id => em.id}
          response.content_type.should == 'application/json'
          response.should be_success
          JSON.parse(response.body)['messages'].should match "Successfully removed #{em.email} from Events"
        end
      end

      context 'event list' do
        it 'redirects to itself with flash message when there is an error' do
          post :index, :listtype => :event, :email => {:name => 'new dude', :email => 'mr_new@example.com'}
          flash[:error].should be
          flash[:error].should match /not have all the required/
          response.should redirect_to email_list_path
        end

        it 'redirects to itself on success' do
          post :index, :method => 'add_email', :listtype => :event, :email => {:name => 'new dude', :email => 'mr_ew@example.com'}
          response.should redirect_to email_list_path
        end
        it 'adds a new email to the email list' do
          expect {
            post :index, :method => 'add_email',  :listtype => :event, :email => {:name => 'new dude', :email => 'mrnew@example.com'}
          }.to change(Email,:count).by(1)
        end
        it 'adds a new email to the email list' do
          post :index, :method => 'add_email', :listtype => :admin, :email => {:name => 'new dude', :email => 'r_new@example.com'}
          AdminMailerList.first.emails.map(&:formatted).should include Email.find_by_email('r_new@example.com').formatted
        end
      end
    end
  end
end
