thisdir = File.expand_path(File.dirname(__FILE__)) + "/"

require thisdir + '../../spec_helper'
require thisdir + 'mobile_shared_spec.rb'

describe Mobile::StudiosController do

  fixtures :studios

  integrate_views

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

