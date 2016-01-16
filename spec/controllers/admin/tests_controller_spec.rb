require 'rails_helper'

describe Admin::TestsController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }

  context 'unauthorized' do
    [:social_icons, :qr, :flash_test, :custom_map].map(&:to_s).each do |endpoint|
      it "#{endpoint} returns error if you're not logged in" do
        get endpoint
        expect(response).to redirect_to '/error'
      end
    end
  end

  describe 'as admin' do
    before do
      login_as admin
    end

    describe '#flash_test' do
      it 'sets up the flash notice/error messages' do
        get :flash_test
        expect(flash[:notice]).to be_present
        expect(flash[:error]).to be_present
      end
    end

    describe '#qr' do
      before do
        @t = Time.zone.now
        Timecop.freeze(@t)
        expect(FileUtils).to receive(:mkdir_p).with %r|/public/images/tmp$|
        allow(Qr4r).to receive(:encode)
      end
      it 'builds a qr image' do
        post :qr, 'string_to_encode' => 'this string', 'pixel_size' => '10'
        expect(assigns(:qrfile)).to eql "/images/tmp/qrtest_#{@t.to_i}.png"
      end
    end

  end

end
