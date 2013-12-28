require 'spec_helper'

include AuthenticatedTestHelper

describe FavoritesController do

  fixtures :users, :roles_users, :roles
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :favorites # even though fixture is empty - this forces a db clear between tests

  [:index].each do |endpoint|
    describe endpoint do
      it "responds failure if not logged in" do
        get endpoint
        response.should redirect_to '/error'
      end
      it "responds failure if not logged in as admin" do
        get endpoint
        response.should redirect_to '/error'
      end
      it "responds success if logged in as admin" do
        login_as(:admin)
        get endpoint
        response.should be_success
      end
    end
  end

  describe "#index" do
    before do
      login_as(:admin)
      u1 = users(:maufan1)
      u2 = users(:jesseponce)
      u3 = users(:annafizyta)

      artist = users(:artist1)

      ArtPiece.any_instance.stub(:artist => double(Artist, :id => 42, :emailsettings => {'favorites' => false}))
      u1.add_favorite ArtPiece.first
      u1.add_favorite users(:artist1)
      u1.add_favorite u2
      u2.add_favorite ArtPiece.first
      u2.add_favorite users(:artist1)
      u3.add_favorite ArtPiece.last

    end
    describe "without views" do
      before do
        get :index
      end

      it "returns success" do
        response.should be_success
      end
      it "assigns :favorites to a hash keyed by user login" do
        assigns(:favorites).should be_a_kind_of AdminFavoritesPresenter
        assigns(:favorites).favorites.count.should be > 0
        assigns(:favorites).favorites.first.first.should be_a_kind_of User
      end

      it "aaron should have 1 favorite art piece" do
        assigns(:favorites).favorites.detect{|f| f[0] == users(:maufan1)}.last.art_pieces.should eql 1
      end

      it "aaron should have 1 favorite art piece" do
        assigns(:favorites).favorites.detect{|f| f[0] == users(:maufan1)}.last.artists.should eql 2
      end

      it "artist 1 should have 2 favorited" do
        assigns(:favorites).favorites.detect{|f| f[0] == users(:artist1)}.last.favorited.should eql 2
      end


    end
    describe "with views" do
      render_views
      before do
        get :index
      end
      it_should_behave_like 'logged in as admin'
      it "aaron should have 1 favorite art piece" do
        assert_select('table.favorites td', :match => users(:maufan1).login)
      end
    end
  end
end
