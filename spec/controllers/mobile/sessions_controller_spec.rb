require 'spec_helper'

describe SessionsController do
  before do
    request.stub(:user_agent => IPHONE_USER_AGENT)
  end
  [:new, :create].each do |endpoint|
    it "#{endpoint} redirects to home" do
      get endpoint
      response.should redirect_to '/'
    end
  end
end
