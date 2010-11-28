require 'spec_helper'

include AuthenticatedTestHelper

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

end

