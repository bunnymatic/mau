require 'rails_helper'

describe ArtistMailer do

  let(:artist) { FactoryGirl.create(:artist, :active) }
  let(:fan) { FactoryGirl.create(:fan, :active) }
  let(:pending_artist) { FactoryGirl.create(:artist, :pending) }

  describe "notification mail for a new signup" do
    before do
      @mail = ArtistMailer.signup_notification(pending_artist)
    end
    it "includes an activation code" do
      expect(@mail.to_s).to match activate_url(:activation_code => pending_artist.activation_code)
    end
  end

  describe "new activated account" do
    let(:mail) { ArtistMailer.activation(artist) }

    it "works" do
      expect(mail.to_s).to include "Your account has been activated."
    end

    it "includes their name" do
      expect(mail.to_s).to include artist.get_name
    end

    it 'includes a welcome message' do
      expect(mail.to_s).to include "YOUR MAU TODO LIST"
    end
  end

  describe 'resend activation mail' do
    before do
      @mail = ArtistMailer.resend_activation(pending_artist)
    end
    it "includes an activation code" do
      expect(@mail.to_s).to match activate_url(:activation_code => pending_artist.activation_code)
    end
  end

  describe "favorite notification" do
    let(:mail) { ArtistMailer.favorite_notification(artist, fan) }
    it "includes an edit link" do
      expect(mail.to_s).to include edit_artist_url(artist, anchor: "notification")
    end
    it "includes a link to the artists page" do
      expect(mail.to_s).to include artist_url(artist)
    end
    it "includes the artist's name" do
      expect(mail.to_s).to include artist.get_name
    end
    it "includes the fan's name" do
      expect(mail.to_s).to include fan.get_name
    end
  end

  describe "notify a featured artist" do
    let(:mail) { ArtistMailer.notify_featured(artist)}
    it 'includes a link to facebook' do
      expect(mail.to_s).to match /facebook.com\/MissionArtists/
    end
    it 'includes a link to twitter' do
      expect(mail.to_s).to match /twitter.com\/sfmau/
    end
  end
end
