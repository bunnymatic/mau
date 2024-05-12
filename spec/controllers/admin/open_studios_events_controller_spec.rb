require 'rails_helper'

describe Admin::OpenStudiosEventsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }

  before do
    login_as admin
  end

  describe '#create' do
    context 'with valid data' do
      let(:attributes) { attributes_for(:open_studios_event, :with_activation_dates, :with_current_special_event) }
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
          expect(OpenStudiosEvent.last.special_event_start_date).to be_present
          expect(OpenStudiosEvent.last.special_event_start_date.to_date).to eq attributes[:start_date]
          expect(OpenStudiosEvent.last.activated_at).to eq attributes[:activated_at]
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

      it 'updates the event with new data' do
        expect(event.reload.start_time).to eq 'whatever'
      end
    end

    context 'with special event data' do
      before do
        post :update,
             params: {
               id: event.id,
               open_studios_event: {
                 special_event_start_date: '2020-10-10',
                 special_event_end_date: '2020-10-11',
                 start_date: '2020-10-1',
                 end_date: '2020-10-15',
               },
             }
      end

      it 'returns success' do
        expect(response).to redirect_to admin_open_studios_events_path
      end

      it 'updates the event' do
        event.reload
        expect(event.special_event_start_date).to eq Time.zone.parse('2020-10-10 00:00:00.000000000 -0700')
        expect(event.special_event_end_date).to eq Time.zone.parse('2020-10-11 00:00:00.000000000 -0700')
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
