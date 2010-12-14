require 'spec_helper'

include AuthenticatedTestHelper

describe FavoritesController do

  integrate_views

  fixtures :users
  
  describe "index" do
    before do
      get :index
    end
    it "returns redirect to login" do
      response.should redirect_to(new_session_path)
    end
    context "while logged in as fan" do
      before do
        @u = users(:aaron)
        login_as(@u)
        get :index
      end
      it "returns success" do
        response.should be_success
      end
    end
    context "while logged in as artist" do
      before do
        @a = users(:artist1)
        login_as(@a)
        get :index
      end
      it "returns success" do
        response.should be_success
      end
    end
  end
end
