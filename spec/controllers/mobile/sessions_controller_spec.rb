require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')
require File.expand_path(File.dirname(__FILE__) + '/../../mobile_shared_spec')

describe SessionsController do
  before do
    request.stubs(:user_agent).returns(IPHONE_USER_AGENT)
  end
  [:new, :create].each do |endpoint| 
    it "#{endpoint} redirects to home" do
      get endpoint
      response.should redirect_to '/'
    end
  end
end


  
