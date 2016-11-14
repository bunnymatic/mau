require 'rails_helper'

describe UserMailer do
  let(:fan) { FactoryGirl.create(:fan) }
  let(:pending) { FactoryGirl.create(:artist, :pending) }

  describe "email for a new member" do
    before do
      @mail = UserMailer.activation(fan)
    end
    it "works" do
      expect(@mail).to have_body_text "Your account has been activated."
    end
  end
  describe "notification mail for a new signup" do
    before do
      @mail = UserMailer.signup_notification(pending)
    end
    it "includes an activation code" do
      expect(@mail).to have_body_text /activate\/\S+/
    end
  end
  describe "new activated account" do
    before do
      @mail = UserMailer.activation(fan)
    end
    it "includes their login" do
      expect(@mail).to have_body_text fan.login
    end
  end

end
