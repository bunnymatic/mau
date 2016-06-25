require 'rails_helper'
describe UpdateArtistService do

  let(:params) { {} }
  let(:artist) { create(:artist) }
  subject(:service) { described_class.new(artist, params) }

  include MockSearchService

  describe ".update" do

    before do
      stub_search_service!
    end

    describe "with user attributes" do
      let(:params) {
        { firstname: "BillyBob" }
      }
      it "updates them" do
        service.update
        expect(artist.reload.firstname).to eql "BillyBob"
      end

      it "registers the change by adding a UserChangeEvent" do
        expect(UserChangedEvent).to receive(:create)
        service.update
      end

    end

    describe "with artist info attributes" do
      let(:params) {
        { artist_info_attributes: { facebook: 'http://newfacebook.example.com' } }
      }
      it "updates them" do
        service.update
        expect(artist.reload.facebook).to eql "http://newfacebook.example.com"
      end
      it "does not change the other artist info properties" do
        bio = artist.artist_info.bio
        info_id = artist.artist_info.id
        expect(bio).to be_present
        service.update
        expect(artist.reload.facebook).to eql "http://newfacebook.example.com"
        expect(artist.artist_info.id).to eql info_id
      end
    end

    describe "with a huge bio update" do
      let(:big_bio) { Faker::Lorem.paragraphs(4).join }
      let(:params) {
        { artist_info_attributes: { bio: big_bio } }
      }
      it "updates things without raising an error" do
        service.update
      end
    end

    describe "when the login changes" do
      let(:params) {
        { login: 'newlogin' }
      }
      it "updates the slug" do
        expect(artist.login).not_to eql "newlogin"
        expect(artist.slug).not_to eql "newlogin"
        service.update
        artist.reload
        expect(artist.slug).to eql "newlogin"
        expect(artist.login).to eql "newlogin"
      end
    end


  end
end
