require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

def setup_admin_user
  u = users(:admin)
  u.roles << roles(:admin)
  u.save
  u
end

describe AdminController do

  integrate_views

  fixtures :users
  fixtures :roles

  [:index, :fans, :stats, :emaillist, :artists_per_day].each do |endpoint|
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
  end
end
