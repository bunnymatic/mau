require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe ArtistMailer do
  fixtures(:users)
  describe "email for a new member" do
    before do
      @mail = ArtistMailer.create_activation(users(:artist1))
    end
    it "works" do
      pending "Nothing good to check"
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
end
