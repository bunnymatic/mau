# frozen_string_literal: true

require 'rails_helper'

describe OpenStudiosController do
  describe '#register' do
    let(:artist) { create(:artist) }
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
