require 'spec_helper'

include AuthenticatedTestHelper

describe FavoritesController do

  integrate_views

  fixtures :users
  fixtures :art_pieces
  
  describe "Create -" do
    before do
      #save artist, artpiece and fan
      @a = users(:artist1)
      @a.save!
      @ap = art_pieces(:artpiece1)
      @ap.user_id = @a.id
      @ap.save!
      @u = users(:aaron)
      @u.save!
    end
    it "GET if not logged in redirects to new session" do
      get :create
      response.should redirect_to(new_session_path)
    end
    it "GET after logged in redirects to users page" do
      login_as(@u)
      get :create
      flash[:error].should be
      response.should redirect_to(user_path(@u))
    end
    it "fails if you are adding your own item" do
      login_as(@a)
      post :create, :fav => { :object => 'Artist', :id => @a.id }
      response.should be_redirect
      flash[:error].should be
    end
    context "as a fan" do
      before do
        @old_favorites = Favorite.find_by_user(@u.id)
        login_as(@u)
        post :create, :fav => { :object => 'Artist', :id => @a.id }
      end
      it "redirect to user page if you are favoriting an artist" do
        response.should redirect_to(user_path(@u))
      end
      it "flash a success notice" do
        flash[:notice].should include_text('added a favorite')
      end
      it "should add a favorite to the user" do
        new_favs = Favorite.find_by_user(@u.id)
        new_favs.count.should eql(@old_favorites.count + 1)
      end
    end
    context "as an artist" do
      before do
        @old_favorites = Favorite.find_by_user(@a.id)
        login_as(@a)
        post :create, :fav => { :object => 'User', :id => @u.id }
      end
      it "redirect to user page if you are favoriting an user" do
        response.should redirect_to(user_path(@a))
      end
      it "flash a success notice" do
        flash[:notice].should include_text('added a favorite')
      end
      it "should add a favorite to the artist" do
        new_favs = Favorite.find_by_user(@a.id)
        new_favs.count.should eql(@old_favorites.count + 1)
      end
    end
    context "while logged out" do
      it "redirects to new session" do
        post :create, :fav => { :object => 'User', :id => @u.id }
        response.should redirect_to(new_session_path)
      end
    end
  end
end
