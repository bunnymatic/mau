require 'spec_helper'

describe UserMailer do
  let(:fan) { FactoryGirl.create(:fan) }
  let(:pending) { FactoryGirl.create(:artist, :pending) }

  describe "email for a new member" do
    before do
      @mail = UserMailer.activation(fan)
    end
    it "works" do
      expect(@mail.body).to include "Your account has been activated."
      expect(@mail.body).to include fan.login
    end
  end
  describe "notification mail for a new signup" do
    before do
      @mail = UserMailer.signup_notification(pending)
    end
    it "includes an activation code" do
      expect(@mail.body).to match /activate\/\S+/
    end
  end
  describe "new activated account" do
    before do
      @mail = UserMailer.activation(fan)
    end
    it "includes their name" do
      expect(@mail.body).to include fan.login
    end
  end

end
