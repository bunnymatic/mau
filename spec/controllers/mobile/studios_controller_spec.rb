require 'spec_helper'
require 'mobile_shared_spec'

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
    it_should_behave_like "non-welcome mobile page"
    
    it "includes a link to each studio" do
      Studio.all.each do |s|
        if s.artists.active.count > 0
          url = studio_path(s)
          url += "/" unless /\/$/.match(url)
          response.should have_tag("a[href=#{url}]", :match => s.name)
        end
      end
    end
  end

  describe "show" do
    before do
      Artist.any_instance.stubs(:representative_piece => nil, :os_participation => {Conf.oslive.to_s => true})
      get :show, :id => @s.id
    end

    it_should_behave_like "a regular mobile page"
    it_should_behave_like "non-welcome mobile page"

    it "includes studio title" do
      response.should have_tag('h2', :match => @s.name)
    end
    it "includes studio address" do
      response.should have_tag('.address', :match => @s.street)
    end

    it "includes list of artists in that studio" do 
      response.should have_tag("li .thumb", :minimum => @s.artists.active.select{|a| a.representative_piece}.count)
    end

    it "includes number of activated artists in the studio"
    it "includes the number of open studios participants"

  end

end

