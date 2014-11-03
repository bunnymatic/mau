require 'spec_helper'

describe UserMailer do
  let(:fan) { FactoryGirl.create(:fan) }
  let(:pending) { FactoryGirl.create(:artist, :pending) }

  describe "email for a new member" do
    before do
      @mail = UserMailer.activation(fan)
    end
    it "works" do
      @mail.body.should include "Your account has been activated."
      @mail.body.should include fan.login
    end
  end
  describe "notification mail for a new signup" do
    before do
      @mail = UserMailer.signup_notification(pending)
    end
    it "includes an activation code" do
      @mail.body.should match /activate\/\S+/
    end
  end
  describe "new activated account" do
    before do
      @mail = UserMailer.activation(fan)
    end
    it "includes their name" do
      @mail.body.should include fan.login
    end
  end

end
