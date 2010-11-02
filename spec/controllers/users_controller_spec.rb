require 'spec_helper'

include AuthenticatedTestHelper

describe UsersController do
  describe "#create" do
    context "with bad params" do
      it "return 404 with :artist = {}" do
        post :create,  :artist => {}
        response.should be_missing
      end
      it "return 404 with :user = {}" do
        post :create, :user => {} 
        response.should be_missing
      end
      it "return 404 with params :mau_fan {}" do
        post :create, :mau_fan => {}
        response.should be_missing
      end
      it "should be 404 with no input params" do
        post :create
        response.should be_missing
      end
    end
    
    # TODO fix these tests
    # this functionality is tested under the old style test suite
    # it appears the "mock" construction doesn't work very well here
    # perhaps it's the STI stuff... not sure
    # in any case, i'm done fighting with rspec

    # possibly there is help here  http://www.killswitchcollective.com/articles/47_testing_rails_controllers_with_rspec
#     context "success" do
#       it "create a new user with value user params and type = 'MAUFan'" do
#         User.should_receive(:new)
#         post :create,  :user => 
#           {:password_confirmation => "blurpit", 
#           :lastname => "bmatic2", 
#           :firstname => "bmatic2", 
#           :password => "blurpit", 
#           :login => "bmatic2", 
#           :email => "bmatic2@b.com"},
#         :type => "MAUFan" 
#         response.should be_redirect
#       end
#       it "create a new artist with valid artists params and type = 'Artist'" do
#         Artist.should_receive(:new)
#         ArtistInfo.should_receive(:new)
#         p "CULPRIT"
#         post :create,  :artist => 
#           {:password_confirmation => "blurpit", 
#           :lastname => "bmatic2", 
#           :firstname => "bmatic2", 
#           :password => "blurpit", 
#           :login => "bmatic2", 
#           :email => "bmatic2@b.com"}, 
#         :type => "Artist" 
#         response.should be_redirect
#       end
#     end
  end

  fixtures :users

  describe "GET edit" do
    before(:each) do
      @a = users(:artist1)
      @a.save!
    end
    context "while not logged in" do
      before(:each) do 
        get :edit
      end
      it "redirects to login" do
        response.should redirect_to(new_session_path)
      end
    end
    context "while logged in" do
      before(:each) do
        login_as(@a)
        get :edit
      end
      it "GET returns 200" do
        response.should be_success
      end
      it "renderers the edit template" do
        response.should render_template("edit.erb")
      end
    end
  end


  describe "update" do
    before(:each) do 
      @u = users(:quentin)
    end
    context "while not logged in" do
      context "with invalid params" do
        before(:each) do
          put :update, :id => @u.id, :user => {}
        end
        it "redirects to new session (login)" do
          response.should redirect_to(new_session_path)
        end
      end
      context "with valid params" do
        before(:each) do
          put :update, :id => @u.id, :user => { :firstname => 'blow' }
        end
        it "redirects to new session (login)" do
          response.should redirect_to(new_session_path)
        end
      end
    end
    context "while logged in" do
      before(:each) do 
        login_as(@u)
      end
      context "with empty params" do
        before(:each) do
          put :update, :id => @u.id, :user => {}
        end
        it "redirects to user edit page" do
          response.should redirect_to(edit_user_path(@u))
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
      end
      context "with valid params" do
        before(:each) do 
          put :update, :id => @u.id, :user => {:firstname => 'blow'}
        end
        it "redirects to user edit page" do
          response.should redirect_to(edit_user_path(@u))
        end
        it "contains flash notice of success" do
          flash[:notice].should eql "Update successful"
        end
        it "updates user attributes" do
          User.find(@u.id).firstname.should eql "blow"
        end
      end
    end
  end
      

  describe "- routes" do
    it "route controller=users, id=10, action=edit to /users/10/edit" do
      route_for(:controller => "users", :id => '10', :action => "edit").should == '/users/10/edit'
    end
  end

  describe "- named routes" do
    it "addprofile as users collection path" do
      addprofile_users_path.should == '/users/addprofile'
    end
    it "upload_profile as users collection path" do
      upload_profile_users_path.should == '/users/upload_profile'
    end
  end
  describe "- route recognition" do
    it "should recognize get /users/10/edit as edit user id = 10" do
      params_from(:get, "/users/10/edit").should == {:controller => 'users', :action => 'edit', :id => '10' }
    end
    
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
