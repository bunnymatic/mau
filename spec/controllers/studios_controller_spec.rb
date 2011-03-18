require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe StudiosController do

  integrate_views

  fixtures :users

  describe "get index" do
    context "while not logged in" do
      before do
        get :index
      end
      it_should_behave_like "not logged in"
    end
    context "while logged in as an art fan" do
      before do
        u = users(:aaron)
        login_as(users(:aaron))
        @logged_in_user = u
        get :index
      end
      it_should_behave_like "logged in user"
    end
  end
  
  describe "keyed studios" do
    Hash[Studio.all.map{|s| [s.name.parameterize('_').to_s, s.name]}].each do |k,v|
      it "should return studio #{v} for key #{k}" do
        get :show, :id => k
        response.should have_tag('h4', :text => v)
      end
    end
  end
end
