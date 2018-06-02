# frozen_string_literal: true

require 'rails_helper'

describe Admin::OpenStudiosEventsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }

  before do
    login_as admin
  end

  describe '#create' do
    context 'with valid data' do
      let(:attributes) { attributes_for(:open_studios_event) }
      def do_create
        post :create, params: { open_studios_event: attributes.except(:id) }
      end

      it 'returns success' do
        do_create
        expect(response).to redirect_to admin_open_studios_events_path
      end

      it 'creates a new open studios event' do
        expect do
          do_create
          expect(OpenStudiosEvent.last.start_time).to eq attributes[:start_time]
        end.to change(OpenStudiosEvent, :count).by(1)
      end
    end
  end

  describe '#update' do
    let!(:event) { create(:open_studios_event) }

    context 'with valid data' do
      before do
        post :update, params: { id: event.id, open_studios_event: { start_time: 'whatever' } }
      end

      it 'returns success' do
        expect(response).to redirect_to admin_open_studios_events_path
      end

      it 'creates a new open studios event' do
        expect(event.reload.start_time).to eq 'whatever'
      end
    end
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
