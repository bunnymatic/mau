# frozen_string_literal: true

require 'rails_helper'

describe Admin::TestsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }

  context 'unauthorized' do
    %w[social_icons qr flash_test custom_map].each do |endpoint|
      context "##{endpoint}" do
        before do
          get endpoint
        end
        it_behaves_like 'not authorized'
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
        travel_to(@t)
        expect(FileUtils).to receive(:mkdir_p).with %r{/public/images/tmp$}
        allow(Qr4r).to receive(:encode)
      end

      it 'builds a qr image' do
        post :qr, params: { string_to_encode: 'this string', pixel_size: '10' }
        expect(assigns(:qrfile)).to eql "/images/tmp/qrtest_#{@t.to_i}.png"
      end
    end
  end
end
