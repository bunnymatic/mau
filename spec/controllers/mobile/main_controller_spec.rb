specdir = File.expand_path(File.dirname(__FILE__)) + "/../../"

require specdir + 'spec_helper'
require specdir + 'mobile_shared_spec'

describe MainController do

  integrate_views

  IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c Safari/419.3'
  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
  end

  describe "index" do
    before do
      get :index
    end
    it "uses the welcome mobile layout" do
      response.layout.should == 'layouts/mobile_welcome'
    end
    it 'includes a menu with 2 items' do
      response.should have_tag('ul.m-nav li', :count => 2)
    end
    it "includes menu item for studios" do
      response.should have_tag('ul.m-nav li a[href="/studios"]', :count => 1)
    end
    it "includes menu item for artists" do
      response.should have_tag('ul.m-nav li a[href="/artists"]', :count => 1)
    end
  end
end

