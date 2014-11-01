
require 'spec_helper'

describe Admin::FavoritesController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:jesse) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:art_pieces) { artist.art_pieces }

  [:index].each do |endpoint|
    describe endpoint do
      it "responds failure if not logged in" do
        get endpoint
        expect(response).to redirect_to '/error'
      end
      it "responds failure if not logged in as admin" do
        get endpoint
        expect(response).to redirect_to '/error'
      end
      it "responds success if logged in as admin" do
        login_as(:admin)
        get endpoint
        expect(response).to be_success
      end
    end
  end

  describe "#index" do

    render_views

    before do
      login_as(:admin)
      fan.add_favorite art_pieces.first
      fan.add_favorite artist
      fan.add_favorite jesse
      jesse.add_favorite artist

      get :index
    end
    it "returns success" do
      expect(response).to be_success
    end
    it_should_behave_like 'logged in as admin'
    it "aaron should have 1 favorite art piece" do
      assert_select('table.favorites td', :match => fan)
    end
  end
end
