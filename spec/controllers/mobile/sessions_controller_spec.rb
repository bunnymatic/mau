require 'spec_helper'

describe SessionsController do
  before do
    pretend_to_be_mobile
  end
  [:new, :create].each do |endpoint|
    it "#{endpoint} redirects to home" do
      get endpoint
      response.should redirect_to '/'
    end
  end
end
