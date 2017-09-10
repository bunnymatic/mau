# frozen_string_literal: true

require 'rails_helper'

describe OpenStudiosController do
  describe '#register' do
    let(:artist) { create(:artist) }
    it 'sends you to your edit page if you are logged in' do
      login_as artist
      get :register
      expect(response).to redirect_to edit_artist_path(artist, anchor: "events")
    end

    it 'sends you to sign in and stores your edit page for return if you are not signed in' do
      get :register
      expect(response).to redirect_to sign_in_path
      expect(session[:return_to]).to eql my_profile_artists_path
    end
  end
end
