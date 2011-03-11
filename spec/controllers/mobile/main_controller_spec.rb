thisdir = File.expand_path(File.dirname(__FILE__)) + "/"

require thisdir + '../../spec_helper'
require thisdir + 'mobile_shared_spec.rb'

describe Mobile::MainController do

  integrate_views
  describe "welcome" do
    before do
      get :welcome
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

