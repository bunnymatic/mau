require 'spec_helper'

describe FavoritesController do
  let(:fan) { FactoryGirl.create(:fan) }
  let(:quentin) { FactoryGirl.create :artist }
  let(:admin) { FactoryGirl.create :user, :admin, :active }
  let(:jesse) { quentin }
  let(:joe) { FactoryGirl.create :artist, :active }
  let(:artist) { FactoryGirl.create :artist, :active }
  let(:pending) { FactoryGirl.create :artist, :pending }
  let(:pending_fan) { FactoryGirl.create :fan, :pending }
  let(:art_pieces) do
    FactoryGirl.create_list :art_piece, 4, :with_tag, artist: artist
  end
  let(:art_piece) do
    art_pieces.first
  end

  before do
    stub_signup_notification
    stub_mailchimp
  end

  describe "#index" do
    context "show" do
      context "while not logged in" do
        before do
          get :index, id: fan.id
        end
        it { expect(response).to be_success }
      end
      context "asking for a user that doesn't exist" do
        before do
          get :index, id: 'bogus'
        end
        it "redirects to all artists" do
          expect(response).to redirect_to artists_path
        end
        it "flashes an error" do
          expect(flash[:error]).to be_present
        end
      end
      context "while logged in as fan with no favorites" do
        let(:artist) { FactoryGirl.create(:artist) }
        before do
          art_pieces
          ArtPiece.any_instance.stub(artist: artist)
          login_as(fan)
          get :index, id: fan.id
        end
        it { expect(response).to be_success }
      end
      context "while logged in as artist" do
        before do
          ArtPiece.any_instance.stub(artist: quentin)
          login_as(artist)
        end
        it 'returns success' do
          get :index, id: artist.id
          expect(response).to be_success
        end
        context "who has favorites" do
          before do
            get :index, id: artist.id
          end
          it { expect(response).to be_success }
        end
      end
      context "logged in as user looking at artist who has favorites " do
        before do
          get :index, id: artist.id
        end
        it { expect(response).to be_success }
      end
    end
  end
end
