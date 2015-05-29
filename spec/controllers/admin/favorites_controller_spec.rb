
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
    before do
      login_as(:admin)
      get :index
    end
    it { expect(response).to be_success }
  end
end
