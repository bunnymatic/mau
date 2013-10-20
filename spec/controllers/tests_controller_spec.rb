require 'spec_helper'

include AuthenticatedTestHelper

describe TestsController do
  [:qr, :flash_test, :calendar_picker, :custom_map].map(&:to_s).each do |endpoint|
    it "#{endpoint} returns error if you're not logged in" do
      get endpoint
      response.should redirect_to '/error'
    end
  end

  describe 'as admin' do
    before do
      login_as :admin
    end

    describe '#flash_test' do
      it 'sets up the flash notice/error messages' do
        flash[:notice].should be_present
        flash[:error].should be_present
      end
    end

  end

end
