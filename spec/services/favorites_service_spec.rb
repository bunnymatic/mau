require 'rails_helper'

describe FavoritesService do
  let(:artist) { create(:artist, :with_art) }
  let(:fan) { create(:fan) }
  subject(:service) { described_class }
  before do
    create_favorite(fan, artist)
    create_favorite(fan, artist.art_pieces.first)
  end

  describe '.add' do
    context 'an artist' do
      it 'adds the artist favorite' do
        service.add fan, artist
        expect(fan.favorites.map(&:favoritable)).to include(artist)
      end
      it 'notifies the artist' do
        expect(FavoritesService).to receive(:notify_favorited_user).with(artist, fan)
        service.add fan, artist
      end
      it "doesn't blow up if the notification fails because of postmark sending issues" do
        failed_mailer = double('Mailer')
        expect(failed_mailer).to receive(:deliver_later).and_raise(Postmark::ApiInputError)
        expect(ArtistMailer).to receive(:favorite_notification).and_return(failed_mailer)
        service.add fan, artist
      end
    end
    context 'an art piece' do
      it 'adds the art piece favorite' do
        service.add fan, artist.art_pieces.last
        expect(fan.favorites.map(&:favoritable)).to include(artist.art_pieces.last)
      end
    end
    context 'a something else' do
      context 'an un favoritable type' do
        it 'raises an error' do
          expect do
            service.add fan, Studio.new
          end.to raise_error InvalidFavoriteTypeError
        end
      end
    end
    context "if you're favoriting your own stuff" do
      it 'does not add a favorite' do
        expect do
          r = service.add artist, artist
          expect(r).to be_blank
        end.to change(Favorite, :count).by(0)
      end
      it 'does not add a favorite art piece' do
        expect do
          r = service.add artist, artist.art_pieces.first
          expect(r).to be_blank
        end.to change(Favorite, :count).by(0)
      end
    end
  end

  describe '.remove' do
    context 'an artist' do
      before do
        fan
        artist
      end
      it 'removes the favorite' do
        expect do
          service.remove fan, artist
        end.to change(Favorite, :count).by(-1)
      end
      it 'removes the association' do
        expect do
          service.remove fan, artist
        end.to change(fan.favorites, :count).by(-1)
      end
    end
    context 'an art piece' do
      before do
        fan
        artist
      end
      it 'removes the favorite' do
        expect do
          service.remove fan, artist.art_pieces.first
        end.to change(Favorite, :count).by(-1)
      end
      it 'removes the association' do
        expect do
          service.remove fan, artist.art_pieces.first
        end.to change(fan.favorites, :count).by(-1)
      end
    end
    context 'an un favoritable type' do
      it 'raises an error' do
        expect do
          service.remove fan, Studio.new
        end.to raise_error InvalidFavoriteTypeError
      end
    end
  end
end
