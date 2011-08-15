require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe EventsController do

  fixtures :users
  
  before do
  end

  it "edit should fail if not logged in" do
    get :edit
    response.should redirect_to new_session_path
  end

  it "edit should work if logged in" do
    login_as(:jesseponce)
    get :edit
    response.should be_success
  end

  it "admin index should fail if not logged in as admin" do
    login_as(:jesseponce)
    get :admin_index
    response.should redirect_to '/error'
  end
  
end
