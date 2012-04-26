require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe TestsController do
  [:qrcode, :flash_test, :calendar_picker, :custom_map].map(&:to_s).each do |endpoint|
    it "#{endpoint} returns error if you're not logged in" do
      get endpoint
      response.should redirect_to '/error'
    end
  end
end
