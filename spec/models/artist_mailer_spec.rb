require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArtistMailer do
  fixtures(:users)
  describe "email for a new member" do
    before do
      @mail = ArtistMailer.create_activation(users(:artist1))
    end
    it "works" do
      @mail.body.should include "Your account has been activated."
      @mail.body.should include users(:artist1).get_name
    end
  end
  describe "activation mail for a new signup" do
    before do
      @mail = ArtistMailer.create_signup_notification(users(:pending))
    end
    it "includes an activation code" do
      @mail.body.should match /activate\/\S+/
    end
  end
  describe "activation mail for a new signup" do
    before do
      @mail = ArtistMailer.create_favorite_notification(users(:artist1), users(:artfan))
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
end
