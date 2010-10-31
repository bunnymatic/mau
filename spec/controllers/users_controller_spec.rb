require 'spec_helper'

include AuthenticatedTestHelper

describe UsersController do
  describe "- routes" do
    it "should map edit to get and form for edit to post" do
      route_for(:controller => "users", :id => '10', :action => "edit").should == '/users/10/edit'
    end
  end

  describe "- named routes" do
    it "should have addprofile as users collection path" do
      addprofile_users_path.should == '/users/addprofile'
    end
    it "should have upload_profile as users collection path" do
      upload_profile_users_path.should == '/users/upload_profile'
    end
  end
  describe "- route recognition" do
    it "should recognize PUT /users/10 as update" do
      params_from(:put, "/users/10").should == {:controller => 'users', :action => 'update', :id => '10' }
    end
    it "should recognize GET /users/10 as show" do
      params_from(:get, "/users/10").should == {:controller => 'users', :action => 'show', :id => '10' }
    end
    it "should recognize POST /users/10 as nonsense (action 10)" do
      params_from(:post, "/users/10").should == {:controller => 'users', :action => '10' }
    end
    it "should recognize DELETE /users/10 as show" do
      params_from(:delete, "/users/10").should == {:controller => 'users', :action => 'destroy', :id => '10' }
    end
  end
end
