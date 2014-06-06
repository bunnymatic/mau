require 'spec_helper'

describe TestsController do
  [:qr, :flash_test, :calendar_picker, :custom_map].map(&:to_s).each do |endpoint|
    it "#{endpoint} returns error if you're not logged in" do
      get endpoint
      expect(response).to redirect_to '/error'
    end
  end

  describe 'as admin' do
    fixtures :users, :roles, :roles_users

    before do
      login_as :admin
    end

    describe '#flash_test' do
      it 'sets up the flash notice/error messages' do
        get :flash_test
        flash[:notice].should be_present
        flash[:error].should be_present
      end
    end

    describe '#qr' do
      before do
        t = Time.zone.now
        Time.zone.stub(:now => t)
        @t = t
        FileUtils.should_receive(:mkdir_p).with %r|/public/images/tmp$|
        Qr4r.stub(:encode)
      end
      it 'builds a qr image' do
        post :qr, 'string_to_encode' => 'this string', 'pixel_size' => '10'
        assigns(:qrfile).should eql "/images/tmp/qrtest_#{@t.to_i}.png"
      end
    end

  end

end
