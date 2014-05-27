require 'spec_helper'

describe ArtistMailer do
  fixtures(:users)

  let(:artist1) { users(:artist1) }
  let(:pending_artist) { users(:pending) }

  describe "notification mail for a new signup" do
    before do
      @mail = ArtistMailer.signup_notification(pending_artist)
    end
    it "includes an activation code" do
      expect(@mail.to_s).to match activate_url(:activation_code => pending_artist.activation_code)
    end
  end

  describe "new activated account" do
    let(:mail) { ArtistMailer.activation(artist1) }

    it "works" do
      expect(mail.to_s).to include "Your account has been activated."
    end

    it "includes their name" do
      expect(mail.to_s).to include artist1.get_name
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
    let(:mail) { ArtistMailer.favorite_notification(artist1, users(:artfan)) }
    it "includes an edit link" do
      expect(mail.to_s).to include (edit_artists_url + "#notification")
    end
    it "includes a link to the artists page" do
      expect(mail.to_s).to include (artist_url(artist1))
    end
    it "includes the artist's name" do
      expect(mail.to_s).to include artist1.get_name
    end
    it "includes the fan's name" do
      expect(mail.to_s).to include users(:artfan).get_name
    end
  end
  describe "notify a featured artist" do
    let(:mail) { ArtistMailer.notify_featured(artist1)}
    it 'includes a link to facebook' do
      expect(mail.to_s).to match /facebook.com\/MissionArtists/
    end
    it 'includes a link to twitter' do
      expect(mail.to_s).to match /twitter.com\/sfmau/
    end
  end
end
