require 'spec_helper'

describe 'UsersController Routes' do

  it "addprofile as users collection path" do
    addprofile_users_path.should eql '/users/addprofile'
  end
  it "upload_profile as users collection path" do
    upload_profile_users_path.should eql '/users/upload_profile'
  end
  it "route controller=users, action=edit to /users/edit" do
    get('/users/edit').should route_to({:controller => "users", :action => "edit"})
  end
  it "should recognize get /users/10/edit as edit user id = 10" do
    (get "/users/10/edit").should route_to( {:controller => 'users', :action => 'edit', :id => '10' })
  end

  it "should recognize PUT /users/10 as update" do
    (put "/users/10").should route_to( {:controller => 'users', :action => 'update', :id => '10' })
  end
  it "should recognize GET /users/10 as show" do
    (get "/users/10").should route_to( {:controller => 'users', :action => 'show', :id => '10' })
  end
  it "should recognize POST /users/10 as nonsense (action 10)" do
    (post "/users/10").should route_to( {:controller => 'users', :action => '10' })
  end
  it "should recognize DELETE /users/10 as destroy user" do
    (delete "/users/10").should route_to( {:controller => 'users', :action => 'destroy', :id => '10' } )
  end

end
