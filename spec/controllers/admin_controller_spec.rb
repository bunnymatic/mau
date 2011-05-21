require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

def setup_admin_user
  u = users(:admin)
  u.roles << roles(:admin)
  u.save
  u
end

describe AdminController do

  fixtures :users
  fixtures :roles

  [:index, :fans, :emaillist, :artists_per_day, :roles, :artists_per_day].each do |endpoint|
    describe endpoint do
      it "responds failure if not logged in" do
        get endpoint
        response.should redirect_to '/error'
      end
      it "responds failure if not logged in as admin" do
        get endpoint
      response.should redirect_to '/error'
      end
      it "responds success if not logged in as admin" do
        login_as(setup_admin_user)
        get endpoint
        response.should be_success
      end
    end
  end
  describe "#index" do
    before do
      login_as(setup_admin_user)
      get :index
    end
    it 'returns success' do
      response.should be_success
    end
    it 'assigns stats hash' do
      assigns(:activity_stats).should be_a_kind_of(Hash)
    end
    it 'assigns correct values for artists yesterday' do
      assigns(:activity_stats)[:yesterday][:artists_activated].should == 1
      assigns(:activity_stats)[:yesterday][:artists_added].should == 1
    end
    it 'assigns correct values for artists last weeek' do
      assigns(:activity_stats)[:last_week][:artists_activated].should == 2
      assigns(:activity_stats)[:last_week][:artists_added].should == 5
    end
    it 'assigns correct values for artists last month' do
      assigns(:activity_stats)[:last_month][:artists_activated].should == 3
      assigns(:activity_stats)[:last_month][:artists_added].should == 7
    end
  end
  describe '#fans' do
    before do
      login_as(setup_admin_user)
      get :fans
    end
    it "responds success" do
      response.should be_success
    end
    it "renders fans.erb" do
      response.should render_template 'fans.erb'
    end
    it "assigns fans" do
      assigns(:fans).length.should == User.active.all(:conditions => 'type <> "Artist"').length
    end
  end
  describe '#roles' do
    before do
      login_as(setup_admin_user)
      get :roles
    end
    it "responds success" do
      response.should be_success
    end
    it "renders roles.erb" do
      response.should render_template 'roles.erb'
    end
    it "assigns artists" do
      assigns(:users).should have(User.active.count).users
    end
    it 'assigns roles' do
      assigns(:roles).should have(Role.count).roles
    end
    it 'assigns roles' do
      assigns(:users_in_roles).keys.should have(Role.count).roles
    end
    context "(view tests)" do
      integrate_views
      
      Role.all.each do |r|
        it "has the role #{r} in a list element" do
          response.should have_tag 'li .role', :count => Role.count
        end
      end
    end
  end

  describe "artists_per_day" do
    before do 
      login_as(setup_admin_user)
      xhr :get, :artists_per_day
    end
    it "returns success" do
      response.should be_success
    end
    it "returns json" do
      response.content_type.should == 'application/json'
    end
    it "json is ready for flotr" do
      j = JSON.parse(response.body)
      j.keys.should include 'series'
      j.keys.should include 'options'
    end
  end

  describe "helpers" do
    describe "artists_per_day" do
      before do
        @artists_per_day = AdminController.new.send(:compute_artists_per_day)
      end
      it "returns an array" do
        @artists_per_day.should be_a_kind_of(Array)
        @artists_per_day.should have_at_least(7).items
      end
      it "returns an entries have date and count" do
        entry = @artists_per_day.first
        entry.should have(2).entries
        Time.at(entry[0].to_i).to_date.should == Date.today
        entry[1].should == 1
      end
      it "does not include nil dates" do
        @artists_per_day.all?{|apd| !apd[0].nil?}.should be
      end
    end
  end
end
