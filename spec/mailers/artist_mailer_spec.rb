require 'spec_helper'

describe ArtistMailer do
  fixtures(:users)
  describe "email for a new member" do
    before do
      @mail = ArtistMailer.activation(users(:artist1))
    end
    it "works" do
      @mail.body.should include "Your account has been activated."
      @mail.body.should include users(:artist1).get_name
    end
  end
  describe "activation mail for a new signup" do
    before do
      @mail = ArtistMailer.signup_notification(users(:pending))
    end
    it "includes an activation code" do
      @mail.body.should match /activate\/\S+/
    end
  end
  describe "activation mail for a new signup" do
    before do
      @mail = ArtistMailer.favorite_notification(users(:artist1), users(:artfan))
    end
    it "includes an edit link" do
      @mail.body.should match /http.*edit/
    end
    it "includes a notification tag" do
      @mail.body.should match /http:.*\#notification/
    end
    it "includes the artist's name" do
      @mail.body.should include users(:artist1).get_name
    end
    it "includes the fan's name" do
      @mail.body.should include users(:artfan).get_name
    end
  end
  describe "notify a featured artist" do
    before do
      @mail = ArtistMailer.notify_featured(users(:artist1))
    end
    it 'includes a link to facebook' do
      @mail.body.should match /facebook.com\/MissionArtists/
    end
    it 'includes a link to twitter' do
      @mail.body.should match /twitter.com\/sfmau/
    end
  end
end
