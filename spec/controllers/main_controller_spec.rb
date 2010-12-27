require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe "successful notes mailer response", :shared => true do
  it "responds success" do
    response.should be_success
  end
  it "response should return status success" do
    @resp['status'].should == 'success'
  end
  it "response should not have messages" do
    @resp['messages'].length.should == 0
  end
end

describe 'has some invalid params', :shared => true do
  it "responds with error status" do
    @resp['status'].should == 'error'
  end
  it "response does not report 'invalid note type'" do
    @resp['messages'].should_not include 'invalid note type'
  end
  it "response reports 'not enough parameters'" do
    @resp['messages'].should include 'not enough parameters'
  end
end

describe MainController do

  integrate_views

  fixtures :users

  describe "get" do
    before do
      get :index
    end
    it "shows search box" do
      response.should have_tag('#search_box')
    end
    it "shows thumbnails" do
      response.should have_tag("#main_thumbs #sampler")
    end
    it "has a feed container" do
      response.should have_tag("#feed_div")
    end
    it "has a header menu" do
      response.should have_tag('#header_bar')
      response.should have_tag('#artisthemission')
    end
    it "has a footer menu" do
      response.should have_tag('#footer_bar')
      response.should have_tag('#footer_copy')
      response.should have_tag('#footer_links')
    end
  end

  describe "- route generation" do
  end
  describe "- route recognition" do
    it "should generate {:controller=>main, action=>venues} from ANY 'venues'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/venues").should == {:controller => 'main', :action => 'venues' }
      end
    end
    it "should generate {:controller=>main, action=>faq} from ANY 'faq'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/faq").should == {:controller => 'main', :action => 'faq' }
      end
    end

    it "should generate {:controller=>main, action=>getinvolved} from ANY 'getinvolved'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/getinvolved").should == {:controller => 'main', :action => 'getinvolved' }
      end
    end
    it "should generate {:controller=>main, action=>about} from ANY 'about'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/about").should == {:controller => 'main', :action => 'about' }
      end
    end
    it "should generate {:controller=>main, action=>privacy} from ANY 'privacy'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/privacy").should == {:controller => 'main', :action => 'privacy' }
      end
    end
    it "should generate {:controller=>main, action=>contact} from ANY 'contact'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/contact").should == {:controller => 'main', :action => 'contact' }
      end
    end
    it "should generate {:controller=>main, action=>news} from ANY 'news'" do
      methods = [:get, :put, :delete, :post]
      methods.each do |m|
        params_from(m, "/news").should == {:controller => 'main', :action => 'news' }
      end
    end
  end

  describe "#news" do
    describe "get" do
      context "while not logged in" do
        before do
          get :news
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :news
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :news
        end
        it_should_behave_like "logged in user"
      end
    end
  end
  describe "#about" do
    describe "get" do
      context "while not logged in" do
        before do
          get :about
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :about
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :about
        end
        it_should_behave_like "logged in user"
      end
    end
  end
  describe "#getinvolved" do
    describe "get" do
      context "while not logged in" do
        before do
          get :getinvolved
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :getinvolved
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :getinvolved
        end
        it_should_behave_like "logged in user"
      end
    end
  end
  describe "#privacy" do
    describe "get" do
      context "while not logged in" do
        before do
          get :privacy
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :privacy
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :privacy
        end
        it_should_behave_like "logged in user"
      end
    end
  end
  describe "#about" do
    describe "get" do
      context "while not logged in" do
        before do
          get :about
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :about
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :about
        end
        it_should_behave_like "logged in user"
      end
    end
  end
  describe "#faq" do
    describe "get" do
      context "while not logged in" do
        before do
          get :faq
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :faq
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :faq
        end
        it_should_behave_like "logged in user"
      end
    end
  end
  describe "#main/openstudios" do
    describe "get" do
      context "while not logged in" do
        before do
          get :openstudios
        end
        it_should_behave_like "not logged in"
      end
      context "while logged in as an art fan" do
        before do
          u = users(:aaron)
          login_as(users(:aaron))
          @logged_in_user = u
          get :openstudios
        end
        it_should_behave_like "logged in user"
      end
      context "while logged in as artist" do
        before do
          a = users(:artist1)
          login_as(users(:artist1))
          @logged_in_user = a
          get :openstudios
        end
        it_should_behave_like "logged in user"
      end
    end
  end

  describe 'notes mailer' do
    context "invalid calls" do
      ['get', 'post', 'put', 'delete'].each do |rtype|
        desc = "returns error if request type is %s" % rtype 
        it desc do
          eval rtype + " :notes_mailer"
          response.should be_missing
        end
      end
    end
    describe "xhr post" do
      before do
        xhr :post, :notes_mailer
        @j = JSON::parse(response.body)
      end
      it "returns success" do
        response.should be_success
      end
      it "returns json" do
        response.content_type.should == 'application/json'
      end
      it "response has error status" do
        @j['status'].should == 'error'
      end
      it "response reports 'invalid note type'" do
        @j['messages'].should include 'invalid note type'
      end
      it "response only has one error message" do
        @j['messages'].size.should == 1
      end
    end

    describe "submission given invalid note_type" do
      before do
        xhr :post, :notes_mailer, :note_type => 'bogus', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it "response has error status" do
        @resp['status'].should == 'error'
      end
      it "response reports 'invalid note type'" do
        @resp['messages'].should include 'invalid note type'
      end
    end
      
    describe "submission given note_type email_list and email only" do
      before do
        xhr :post, :notes_mailer, :note_type => 'email_list', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'Email confirm cant be blank'" do
        @resp['messages'].should include "Email confirm can't be blank"
      end
      it "response reports 'emails do not match'" do
        @resp['messages'].should include 'emails do not match'
      end
    end
    describe "submission given note_type feedlink with email only" do
      before do
        xhr :post, :notes_mailer, :note_type => 'feed_submission', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'feed url cannot be empty'" do
        @resp['messages'].should include 'feed url can\'t be empty'
      end
    end
    describe "submission given note_type inquiry and email only" do
      before do
        xhr :post, :notes_mailer, :note_type => 'inquiry', :email => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "response reports 'Email confirm cant be blank'" do
        @resp['messages'].should include "Email confirm can't be blank"
      end
      it "response reports 'emails do not match'" do
        @resp['messages'].should include 'emails do not match'
      end
      it "response reports 'note cannot be empty'" do
        @resp['messages'].should include 'note cannot be empty'
      end
    end
    describe "submission given note_type inquiry, both emails but no inquiry" do
      before do
        xhr :post, :notes_mailer, :note_type => 'inquiry', 
          :email => 'a@b.com', :email_confirm => 'a@b.com'
        @resp = JSON::parse(response.body)
      end
      it_should_behave_like "has some invalid params"
      it "has only 1 message" do
        @resp['messages'].size == 1
      end
      it "message is note cannot be empty" do
        @resp['messages'].should include 'note cannot be empty'
      end
    end
    describe "submission with valid params" do
      context "email_list" do
        before do
          xhr :post, :notes_mailer, :note_type => 'email_list', 
            :email => 'a@b.com', :email_confirm => 'a@b.com'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like "successful notes mailer response"
        it 'triggers FeedbackMailer.deliver_feedback' do
          FeedbackMailer.expects(:deliver_feedback).with() do |f|
            f.login.should == 'anon'
            f.comment.should include 'a@b.com'
            f.subject.should == 'MAU Submit Form : email_list'
            f.email.should == 'a@b.com'
          end
          xhr :post, :notes_mailer, :note_type => 'email_list', 
            :email => 'a@b.com', :email_confirm => 'a@b.com'
        end
        it 'adds a feedback item to the db' do
          expect {
            xhr :post, :notes_mailer, :note_type => 'email_list', 
                 :email => 'a@b.com', :email_confirm => 'a@b.com'
          }.to change(Feedback, :count).by(1)
        end
      end
      context "inquiry" do
        before do
          xhr :post, :notes_mailer, :note_type => 'inquiry', 
            :inquiry => 'cool note',
            :email => 'a@b.com', :email_confirm => 'a@b.com'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end
      context "help" do
        before do
          xhr :post, :notes_mailer, :note_type => 'help', 
            :inquiry => 'cool note',
            :email => 'a@b.com', :email_confirm => 'a@b.com'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'
      end
      context "feeds link" do
        before do
          xhr :post, :notes_mailer, :note_type => 'feed_submission', 
            :feedlink => 'http://feed/feed.rss'
          @resp = JSON::parse(response.body)
        end
        it_should_behave_like 'successful notes mailer response'

        it 'triggers FeedbackMailer.deliver_feedback' do
          FeedbackMailer.expects(:deliver_feedback).with() do |f|
            f.login.should == 'anon'
            f.comment.should include 'feed.rss'
            f.subject.should == 'MAU Submit Form : feed_submission'
          end
          xhr :post, :notes_mailer, :note_type => 'feed_submission', 
            :feedlink => 'http://feed/feed.rss'
        end
      end
    end
  end
end

