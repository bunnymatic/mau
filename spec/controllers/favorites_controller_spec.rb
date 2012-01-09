require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe FavoritesController do

  fixtures :users
  fixtures :art_pieces
  fixtures :artist_infos
  fixtures :roles
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

      ArtPiece.any_instance.stubs(:artist => stub(:id => 42, :emailsettings => {'favorites' => false}))
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
        assigns(:favorites).should be_is_a Hash
        logins = User.all.map(&:login)
        assigns(:favorites).count.should be > 0
        assigns(:favorites).keys.all?{|login| logins.include? login}.should be_true
      end
      
      it "aaron should have 1 favorite art piece" do
        assigns(:favorites)[users(:maufan1).login][:art_pieces].should == 1
      end
      
      it "aaron should have 1 favorite art piece" do
        assigns(:favorites)[users(:maufan1).login][:artists].should == 2
      end
      
      it "artist 1 should have 2 favorited" do
        assigns(:favorites)[users(:artist1).login][:favorited].should == 2
      end


    end
    describe "with views" do
      integrate_views
      before do
        get :index
      end
      it "aaron should have 1 favorite art piece" do
        response.should have_tag('table.favorites td', :match => users(:maufan1).login)
      end
    end
  end
end

