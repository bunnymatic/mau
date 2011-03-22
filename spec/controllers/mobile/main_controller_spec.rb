specdir = File.expand_path(File.dirname(__FILE__)) + "/../../"

require specdir + 'spec_helper'
require specdir + 'mobile_shared_spec'

describe MainController do

  integrate_views

  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
  end

  describe "index" do
    before do
      get :index
    end
    it_should_behave_like "a regular mobile page"
    it "uses the welcome mobile layout" do
      response.layout.should == 'layouts/mobile_welcome'
    end
    it 'includes a menu with 2 items' do
      response.should have_tag('ul li', :count => 5)
    end
    it "includes menu item for studios" do
      response.should have_tag('ul li a[href="/studios/"]', :count => 1)
    end
    it "includes menu item for artists" do
      response.should have_tag('ul li a[href="/artists/thumbs/"]', :count => 1)
    end
    it "includes menu item for about" do
      response.should have_tag('ul li a[href="/about/"]', :count => 1)
    end

  end
end

