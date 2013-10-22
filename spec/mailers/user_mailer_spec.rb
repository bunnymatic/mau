require 'spec_helper'

describe UserMailer do
  fixtures(:users)
  describe "email for a new member" do
    before do
      @mail = UserMailer.activation(users(:maufan1))
    end
    it "works" do
      @mail.body.should include "Your account has been activated."
      @mail.body.should include users(:maufan1).firstname
    end
  end
  describe "activation mail for a new signup" do
    before do
      @mail = UserMailer.signup_notification(users(:pending))
    end
    it "includes an activation code" do
      @mail.body.should match /activate\/\S+/
    end
  end
end
