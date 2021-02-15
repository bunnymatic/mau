require 'rails_helper'

describe OpenStudiosController do
  let(:artist) { create(:artist) }
  let(:active_artist_doing_open_studios) do
    current_os
    create(:artist, :active, doing_open_studios: true)
  end
  let(:current_os) { create(:open_studios_event) }

  describe '#show' do
    context 'with virtual_open_studios flag on' do
      before do
        mock_app_config(:features, { virtual_open_studios: true })
      end

      it 'renders successfully if the artist is active and doing open studios' do
        get :show, params: { id: active_artist_doing_open_studios }
        expect(response).to be_ok
      end

      it 'redirects to open_studios_path if the artist is not doing open studios' do
        get :show, params: { id: artist }
        expect(response).to redirect_to(open_studios_path)
        expect(flash[:error]).to eq "It doesn't look like that artist is doing open studios"
      end

      it 'redirects to open_studios_path if the artist is unknown' do
        get :show, params: { id: 'nobody-we-know' }
        expect(response).to redirect_to(open_studios_path)
        expect(flash[:error]).to eq "It doesn't look like that artist is doing open studios"
      end

      it 'redirects to open_studios_path if the artist is not active' do
        artist.update(state: :pending)
        get :show, params: { id: artist }
        expect(response).to redirect_to(open_studios_path)
        expect(flash[:error]).to eq "It doesn't look like that artist is doing open studios"
      end
    end

    context 'with virtual open studios flag off' do
      before do
        mock_app_config(:features, { virtual_open_studios: false })
      end
      it 'renders error page' do
        get :show, params: { id: active_artist_doing_open_studios }
        expect(response).to redirect_to('/error')
      end
    end
  end

  describe '#register' do
    it 'sends you to your edit page if you are logged in' do
      login_as artist
      get :register
      expect(response).to redirect_to(register_for_current_open_studios_artists_path)
    end

    it 'sends you to sign in and stores your edit page for return if you are not signed in' do
      get :register
      expect(response).to redirect_to(sign_in_path)
      expect(session[:return_to]).to eql(register_for_current_open_studios_artists_path)
    end
  end
end
