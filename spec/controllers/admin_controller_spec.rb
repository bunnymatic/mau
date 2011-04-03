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

  [:index, :fans, :stats, :emaillist, :artists_per_day, :roles].each do |endpoint|
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

end
