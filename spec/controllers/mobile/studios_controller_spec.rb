specdir = File.expand_path(File.dirname(__FILE__)) + "/../../"

require specdir + 'spec_helper'
require specdir + 'mobile_shared_spec'

describe StudiosController do

  fixtures :studios
  fixtures :users

  integrate_views

  before do
    # do mobile
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
    assert(Studio.all.length >= 2)
    @s = Studio.all[2]
    Artist.active.each do |a|
      a.studio = @s
      a.save!
    end
  end

  describe "index" do
    before do
      get :index
    end

    it_should_behave_like "a regular mobile page"
    
    it "includes a link to each studio" do
      Studio.all.each do |s|
        url = studio_path(s)
        response.should have_tag("a[href=#{url}]", :match => s.name)
      end
    end
  end

  describe "show" do
    before do
      get :show, :id => @s.id
    end

    it_should_behave_like "a regular mobile page"

    it "includes studio title" do
      response.should have_tag('h3', :match => @s.name)
    end
    it "includes studio address" do
      response.should have_tag('.address', :match => @s.street)
    end

    it "includes list of artists in that studio" do 
      response.should have_tag("li.mobile-menu", :minimum => @s.artists.count)
    end

    it "includes number of activated artists in the studio"
    it "includes the number of open studios participants"

  end

end

