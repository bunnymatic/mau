require 'rails_helper'

describe FavoritesService do

  let(:artist) { create(:artist, :with_art) }
  let(:fan) { create(:fan) }
  subject(:service) { described_class }
  before do
    Favorite.create(favoritable_type: "Artist", favoritable_id: artist.id, user_id: fan.id)
    Favorite.create(favoritable_type: "ArtPiece", favoritable_id: artist.art_pieces.first.id, user_id: fan.id)
  end

  describe ".add" do
    context "an artist" do
      it "adds the artist favorite" do
        service.add fan, artist
        expect(fan.favorites.map(&:to_obj)).to include(artist)
      end
      it "notifies the artist" do
        expect(FavoritesService).to receive(:notify_favorited_user).with(artist, fan)
        service.add fan, artist
      end
      it "doesn't blow up if the notification fails because of postmark sending issues" do
        failed_mailer = double("Mailer")
        expect(failed_mailer).to receive(:deliver_later).and_raise(Postmark::InvalidMessageError)
        expect(ArtistMailer).to receive(:favorite_notification).and_return(failed_mailer)
        service.add fan, artist
      end

    end
    context "an art piece" do
      it "adds the art piece favorite" do
        service.add fan, artist.art_pieces.last
        expect(fan.favorites.map(&:to_obj)).to include(artist.art_pieces.last)
      end
    end
    context "a something else" do
      context "an un favoritable type" do
        it 'raises an error' do
          expect {
            service.add fan, Studio.new
          }.to raise_error InvalidFavoriteTypeError
        end
      end
    end
    context "if you're favoriting your own stuff" do
      it "does not add a favorite" do
        expect {
          r = service.add artist, artist
          expect(r).to be_blank
        }.to change(Favorite, :count).by(0)
      end
      it "does not add a favorite art piece" do
        expect {
          r = service.add artist, artist.art_pieces.first
          expect(r).to be_blank
        }.to change(Favorite, :count).by(0)
      end
    end
  end

  describe ".remove" do
    context "an artist" do
      before do
        fan
        artist
      end
      it 'removes the favorite' do
        expect {
          service.remove fan, artist
        }.to change(Favorite, :count).by(-1)
      end
      it 'removes the association' do
        expect {
          service.remove fan, artist
        }.to change(fan.favorites, :count).by(-1)
      end
    end
    context "an art piece" do
      before do
        fan
        artist
      end
      it 'removes the favorite' do
        expect {
          service.remove fan, artist.art_pieces.first
        }.to change(Favorite, :count).by(-1)
      end
      it 'removes the association' do
        expect {
          service.remove fan, artist.art_pieces.first
        }.to change(fan.favorites, :count).by(-1)
      end
    end
    context "an un favoritable type" do
      it 'raises an error' do
        expect {
          service.remove fan, Studio.new
        }.to raise_error InvalidFavoriteTypeError
      end
    end
  end
end
