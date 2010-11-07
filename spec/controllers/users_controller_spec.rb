require 'spec_helper'

include AuthenticatedTestHelper

describe UsersController do

  integrate_views

  fixtures :users

  describe "#create" do
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
   
    context "with partial params" do
      before do
        # disable sweep of flash.now messages
        # so we can test them
        @controller.instance_eval{flash.stub!(:sweep)}
      end
      
      context "login = 'newuser'" do
        before do
          post :create, :user => { :login => 'newuser' }, :type => "MAUFan" 
        end
        
        it "login=>newuser : should return success" do 
          response.should be_success
        end
        
        it "sets a flash.now indicating failure" do
          post :create, :user => { :login => 'newuser' }, :type => "MAUFan" 
        end
      end
    end
    context "valid user params and type = MAUFan" do
      before do
        post :create, :mau_fan => { :login => 'newuser',
          :password_confirmation => "blurpit", 
          :lastname => "bmatic2", 
          :firstname => "bmatic2", 
          :password => "blurpit", 
          :email => "bmatic2@b.com" }, :type => "MAUFan" 
      end
      it "redirects to index" do
        response.should redirect_to( root_url )
      end
      it "sets flash indicating that activation email has been sent" do
        flash[:notice].should include_text(" email with your activation code")
      end
      context "creates an account" do

        before do
          @found_user = User.find_by_login("newuser")
        end
        it "in the user database" do
          @found_user.should be
        end
        it "whose state is 'pending'" do
          @found_user.state.should be == 'pending'
        end
        it "whose type is 'MAUFan'" do
          @found_user.type == 'MAUFan'
        end
      end
      it "should register as a fan account" do
        MAUFan.find_by_login("newuser").should be
      end
      it "should not register as an artist account" do
        Artist.find_by_login("newuser").should be_nil
      end
      it "should register as user account" do
        User.find_by_login("newuser").should be
      end
    end
  end
  context "valid artist params and type = Artist" do
    before do
      post :create, :artist => { :login => 'newuser2',
        :password_confirmation => "blurpt", 
        :lastname => "bmatic", 
        :firstname => "bmatic", 
        :password => "blurpt", 
        :email => "bmatic2@b.com" }, :type => "Artist" 
    end
    it "redirects to index" do
      response.should redirect_to( root_url )
    end
    it "sets flash indicating that activation email has been sent" do
      flash[:notice].should include_text(" email with your activation code")
    end
    context "creates an account" do
      before do
        @found_artist = User.find_by_login("newuser2")
      end
      it "in the artist database" do
        @found_artist.should be
      end
      it "whose state is 'pending'" do
        @found_artist.state.should be == 'pending'
      end
      it "whose type is 'Artist'" do
        @found_artist.type == 'Artist'
      end
    end
    it "should not register as a fan account" do
      MAUFan.find_by_login("newuser2").should be_nil
    end
  end

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
