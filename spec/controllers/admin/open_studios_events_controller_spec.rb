# frozen_string_literal: true
require 'rails_helper'

describe Admin::OpenStudiosEventsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }

  before do
    login_as admin
  end

  describe '#clear_cache' do
    it 'clears the OS Event cache' do
      expect(OpenStudiosEventService).to receive(:clear_cache)
      get :clear_cache
    end

    it 'redirects to the index page' do
      get :clear_cache
      expect(response).to redirect_to admin_open_studios_events_path
    end
  end
end
