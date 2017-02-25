# frozen_string_literal: true
require 'rails_helper'

describe Admin::FavoritesController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:jesse) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:artist) { FactoryGirl.create(:artist, :active, :with_art) }
  let(:art_pieces) { artist.art_pieces }

  describe "#index" do
    context "as an admin" do
      before do
        login_as(:admin)
        get :index
      end
      it { expect(response).to be_success }
    end
    context "as a non-admin" do
      before do
        login_as jesse
        get :index
      end
      it "responds failure if not logged in" do
        expect(response).to redirect_to '/error'
      end
      it "responds failure if not logged in as admin" do
        expect(response).to redirect_to '/error'
      end
    end
  end
end
