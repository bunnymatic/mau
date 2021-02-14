require 'rails_helper'

describe Admin::FavoritesController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:fan) { FactoryBot.create(:fan, :active) }
  let(:jesse) { FactoryBot.create(:artist, :active, :with_art) }
  let(:artist) { FactoryBot.create(:artist, :active, :with_art) }
  let(:art_pieces) { artist.art_pieces }

  describe '#index' do
    context 'as an admin' do
      before do
        login_as(:admin)
        get :index
      end
      it { expect(response).to be_successful }
    end
    context 'as a non-admin' do
      before do
        login_as jesse
        get :index
      end
      it_behaves_like 'not authorized'
    end
  end
end
