require 'rails_helper'

describe OpenStudiosController do
  let(:artist) { create(:artist) }
  let(:active_artist_doing_open_studios) do
    current_os
    create(:artist, :active, doing_open_studios: true)
  end
  let(:current_os) { create(:open_studios_event) }

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
