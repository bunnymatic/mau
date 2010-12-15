require 'spec_helper'

include AuthenticatedTestHelper

describe FavoritesController do

  integrate_views

  fixtures :users
  fixtures :art_pieces

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
      context "who has favorites" do
        before do
          Artist.any_instance.stubs(:get_profile_path).returns("/this")
          ArtPiece.any_instance.stubs(:get_path).with('thumb').returns("/this")
          ap = art_pieces(:hot)
          ap.artist_id = users(:joeblogs)
          ap.save!
          aa = users(:joeblogs)
          @a.add_favorite ap
          @a.add_favorite aa
          assert @a.fav_artists.count >= 1
          assert @a.fav_art_pieces.count >= 1
          get :index
        end
        it "returns success" do
          response.should be_success
        end
        it "shows the favorites sections" do
          response.should have_tag('h5', :include_text => 'Artists')
          response.should have_tag('h5', :include_text => 'Art Pieces')
        end
        it "shows the 1 art piece favorite" do
          pending "can't figure out how to stub out the helper method draw_favorite"
          response.should have_tag('.favorites .art_pieces .thumb', :count => 1)
        end
        it "shows the 1 artist favorite" do
          pending "can't figure out how to stub out the helper method draw_favorite"
          response.should have_tag('.favorites .artists .thumb', :count => 1)
        end
      end
    end
  end
end
