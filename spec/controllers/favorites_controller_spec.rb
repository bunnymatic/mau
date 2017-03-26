# frozen_string_literal: true
require 'rails_helper'

describe FavoritesController do
  let(:fan) { FactoryGirl.create(:fan) }
  let(:artist) { FactoryGirl.create :artist }
  let(:admin) { FactoryGirl.create :user, :admin, :active }
  let(:joe) { FactoryGirl.create :artist, :active }
  let(:artist) { FactoryGirl.create :artist, :active, :with_art }
  let(:pending) { FactoryGirl.create :artist, :pending }
  let(:pending_fan) { FactoryGirl.create :fan, :pending }
  let(:art_pieces) { artist.art_pieces }
  let(:art_piece) { art_pieces.first }

  before do
    stub_signup_notification
    stub_mailchimp
  end

  describe '#create' do
    context 'while not logged in' do
      before do
        post :create, xhr: true, params: { user_id: fan.id }
      end
      it_should_behave_like 'refuses access by xhr'
    end

    context 'while logged in' do
      before do
        login_as fan
      end
      it "does not create an artist for user that doesn't match login" do
        expect do
          post :create, xhr: true, params: { user_id: artist.id, favorite: { type: 'Artist', id: artist.id } }

          expect(response).to redirect_to user_path(fan)
          expect(artist.reload.favorites).to be_empty
        end.to change(fan.favorites, :count).by(0)
      end

      context 'adding a favorite artist' do
        before do
          post :create, xhr: true, params: { user_id: fan.id, favorite: { type: 'Artist', id: artist.id } }
        end
        it 'returns success' do
          r = JSON.parse(response.body)
          expect(r['message']).to include 'added to your favorites'
        end
        it 'adds the artist' do
          favs = fan.reload.favorites
          expect(favs.map(&:favoritable_id)).to include artist.id
        end
      end

      context 'adding a favorite artist by slug' do
        before do
          post :create, xhr: true, params: { user_id: fan.id, favorite: { type: 'Artist', id: artist.slug } }
        end
        it 'adds the artist' do
          favs = fan.reload.favorites
          expect(favs.map(&:favoritable_id)).to include artist.id
        end
      end

      context 'addding an art_piece' do
        context 'as ajax post(xhr)' do
          before do
            login_as fan
            post :create, xhr: true, params: { user_id: fan.id, favorite: { type: 'ArtPiece', id: art_piece.id } }
          end
          it_should_behave_like 'successful json'
          it 'adds favorite to user' do
            u = User.find(fan.id)
            favs = u.favorites
            expect(favs.map(&:favoritable_id)).to include art_piece.id
          end
          it 'sets flash with escaped name' do
            expect(JSON.parse(response.body)['message']).to include html_encode(art_piece.title)
          end
          it 'adds favorite to user' do
            favs = fan.reload.favorites
            expect(favs.map(&:favoritable_id)).to include art_piece.id
          end
        end
      end
      context 'add a favorite bogus model' do
        before do
          @nfavs = artist.favorites.count
          post :create, xhr: true, params: { user_id: fan.id, favorite: { type: 'bogus', id: art_piece.id } }
        end
        it 'returns 404' do
          expect(response).to be_missing
          expect(response.code).to eql('404')
        end
      end
    end
  end

  describe '#destroy' do
    before do
      FavoritesService.add fan, artist
      @favorite = fan.reload.favorites.first
    end
    context "when logged in as the favorite's user" do
      before do
        login_as fan
        delete :destroy, params: { user_id: fan.id, id: @favorite.id }
      end
      it 'redirects to the referer' do
        expect(response).to redirect_to(SHARED_REFERER)
      end
      it 'that artist is no longer a favorite' do
        favs = fan.reload.favorites
        expect(favs.map(&:favoritable_id)).not_to include artist.id
      end
    end
    context "when logged in as not favorite's user" do
      before do
        login_as joe
        delete :destroy, params: { user_id: fan.id, id: @favorite.id }
      end
      it 'redirects to the referer' do
        expect(response).to redirect_to(user_path(joe))
      end
      it 'that artist is no longer a favorite' do
        favs = fan.reload.favorites
        expect(favs.map(&:favoritable_id)).to include artist.id
      end
    end
  end

  describe '#index' do
    context 'while not logged in' do
      before do
        get :index, params: { id: fan.id }
      end
      it { expect(response).to be_success }
    end

    context "asking for a user that doesn't exist" do
      before do
        get :index, params: { id: 'bogus' }
      end
      it 'redirects to all artists' do
        expect(response).to redirect_to artists_path
      end
      it 'flashes an error' do
        expect(flash[:error]).to be_present
      end
    end

    context 'while logged in as fan with no favorites' do
      before do
        login_as(fan)
        get :index, params: { id: fan.id }
      end
      it { expect(response).to be_success }
    end

    context 'while logged in as artist' do
      before do
        login_as(artist)
      end
      it 'returns success' do
        get :index, params: { id: artist.id }
        expect(response).to be_success
      end
    end
  end
end
