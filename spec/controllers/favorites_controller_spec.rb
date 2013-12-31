
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
    let(:fan) { users(:maufan1) }
    let(:jesse) { users(:jesseponce) }
    let(:anna) { users(:annafizyta) }
    let(:artist) { users(:artist1) }
    let(:art_pieces) { [ArtPiece.first, ArtPiece.last] }
  
    render_views

    before do
      login_as(:admin)
      fan.add_favorite art_pieces.first
      fan.add_favorite artist
      fan.add_favorite jesse
      jesse.add_favorite anna

      get :index
    end
    it "returns success" do
      response.should be_success
    end
    it_should_behave_like 'logged in as admin'
    it "aaron should have 1 favorite art piece" do
      assert_select('table.favorites td', :match => fan)
    end
  end
end
