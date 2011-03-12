specdir = File.expand_path(File.dirname(__FILE__)) + "/../../"

require specdir + 'spec_helper'
require specdir + 'mobile_shared_spec'

describe StudiosController do

  fixtures :studios

  integrate_views

  IPHONE_USER_AGENT = 'Mozilla/5.0 (iPhone; U; XXXXX like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A477c Safari/419.3'
  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
  end

  describe "index" do
    before do
      assert(Studio.all.length > 0)
      get :index
    end

    it_should_behave_like "a regular mobile page"
    
    it "includes a link to each studio" do
      Studio.all.each do |s|
        url = studio_path(s)
        response.should have_tag("a[href=#{url}]", :match => s.name)
      end
    end
    
    it "includes studio address"
    it "includes number of activated artists in the studio"
    it "includes the number of open studios participants"

  end

  describe "show" do
    before do
      @s = Studio.all[2]
      get :show, :id => @s.id
    end

    it_should_behave_like "a regular mobile page"

    it "includes studio title" do
      response.should have_tag('h4', :match => @s.name)
    end
    it "includes studio address"
    it "includes list of artists in that studio" do 
      response.should have_tag("li.mobile-menu", :minimum => @s.artists.count)
    end
    
  end

end

