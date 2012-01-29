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
      it_should_behave_like 'returns success'
      [ [:feedback, 2, 'FeedbackMailerList'],
        [:admin, 2, 'AdminMailerList'],
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
      it 'renders the lists' do
        assert_select '.email_lists ul.listtypes > li', :count => 3
      end
      it 'renders add email forms for each list' do
        assert_select '.email_lists ul.listtypes form', :count => 3
      end
    end
    describe 'POST' do
      context 'event list' do
        it 'returns success' do
          post :index, :listtype => :event, :email => {:name => 'new dude', :email => 'mr_new@example.com'}
          assert_select('.error-msg', /not have all the required/)
        end

        it 'returns success' do
          post :index, :method => 'add_email', :listtype => :event, :email => {:name => 'new dude', :email => 'mr_ew@example.com'}
          response.should be_success
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
