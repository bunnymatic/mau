require 'spec_helper'

describe ArtistMailer do
  fixtures(:users)

  let(:artist1) { users(:artist1) }
  let(:pending_artist) { users(:pending) }

  describe "email for a new member" do
    before do
      @mail = ArtistMailer.activation(artist1)
    end
    it "works" do
      @mail.body.should include "Your account has been activated."
      @mail.body.should include artist1.get_name
    end
  end

  describe "notification mail for a new signup" do
    before do
      @mail = ArtistMailer.signup_notification(pending_artist)
    end
    it "includes an activation code" do
      @mail.body.should match activate_url(:activation_code => pending_artist.activation_code)
    end
  end

  describe "new activated account" do
    before do
      @mail = ArtistMailer.activation(artist1)
    end
    it "includes their name" do
      @mail.body.should include artist1.get_name
    end
    it 'includes a welcome message' do
      @mail.body.should include "YOUR MAU TODO LIST"
    end
  end

  describe 'resend activation mail' do
    before do
      @mail = ArtistMailer.resend_activation(pending_artist)
    end
    it "includes an activation code" do
      @mail.body.should match activate_url(:activation_code => pending_artist.activation_code)
    end
  end
  describe "favorite notification" do
    before do
      @mail = ArtistMailer.favorite_notification(artist1, users(:artfan))
    end
    it "includes an edit link" do
      @mail.body.should include (edit_artists_url + "#notification")
    end
    it "includes a link to the artists page" do
      @mail.body.should include (artist_url(artist1))
    end
    it "includes the artist's name" do
      @mail.body.should include artist1.get_name
    end
    it "includes the fan's name" do
      @mail.body.should include users(:artfan).get_name
    end
  end
  describe "notify a featured artist" do
    before do
      @mail = ArtistMailer.notify_featured(artist1)
    end
    it 'includes a link to facebook' do
      @mail.body.should match /facebook.com\/MissionArtists/
    end
    it 'includes a link to twitter' do
      @mail.body.should match /twitter.com\/sfmau/
    end
  end
end
