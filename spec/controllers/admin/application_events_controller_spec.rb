# frozen_string_literal: true

require 'rails_helper'

describe Admin::ApplicationEventsController do
  let(:admin) { FactoryBot.create(:artist, :admin) }
  let(:generic_event) { events.detect { |e| e.is_a? GenericEvent } }
  let(:os_event) { events.detect { |e| e.is_a? OpenStudiosSignupEvent } }
  let!(:events) do
    Array.new(6) do |x|
      [
        FactoryBot.create(:open_studios_signup_event, created_at: x.weeks.ago, data: { user: 'artist' }),
        FactoryBot.create(:generic_event, created_at: x.weeks.ago, data: { user: 'artist' }),
      ]
    end.flatten
  end

  describe 'unauthorized #index' do
    before do
      get :index
    end
    it_behaves_like 'not authorized'
  end
  describe 'index.html (as admin)' do
    let(:limit) { nil }
    let(:since) { nil }
    before do
      login_as(admin)
      get :index, params: {
        query: {
          number_of_records: limit,
          since: since,
        },
      }
    end
    context 'with no params' do
      it 'returns success' do
        expect(response).to be_successful
      end
      it 'fetches all events by type' do
        events_by_type = assigns(:events_by_type)
        expect(events_by_type).not_to be_empty
        expect(events_by_type.keys).to include GenericEvent
        expect(events_by_type.keys).to include OpenStudiosSignupEvent
        generics = events_by_type[GenericEvent]
        expect(generics.size).to eq(6)
        expect(generics.first.message).to eql generic_event.message
        oss = events_by_type[OpenStudiosSignupEvent]
        expect(oss.size).to eq(6)
        expect(oss.first.data).to eql(os_event.data)
      end
    end
    context 'with a limit of 2' do
      let(:limit) { 2 }

      it 'returns success' do
        expect(response).to be_successful
      end
      it 'fetches all events by type' do
        events_by_type = assigns(:events_by_type)
        expect(events_by_type).not_to be_empty
        expect(events_by_type.keys).to include GenericEvent
        expect(events_by_type.keys).to include OpenStudiosSignupEvent
        generics = events_by_type[GenericEvent]
        expect(generics.size).to eq(2)
        expect(generics.first.message).to eql generic_event.message
        oss = events_by_type[OpenStudiosSignupEvent]
        expect(oss.size).to eq(2)
        expect(oss.first.data).to eql(os_event.data)
      end
    end
    context 'with a limit of A' do
      let(:limit) { 'A' }

      it 'returns success' do
        expect(response).to be_successful
      end
      it 'fetches all events by type' do
        events_by_type = assigns(:events_by_type)
        expect(events_by_type.values.flatten).to have(12).items
      end
    end

    context 'with a since date' do
      let(:since) { 1.day.ago.localtime.to_s }

      it 'returns success' do
        expect(response).to be_successful
      end
      it 'fetches all events since that date' do
        events = assigns(:events_by_type).values.flatten
        expect(events).to have(2).events
        expect(events.all? { |ev| ev.created_at > 1.day.ago })
      end
    end
  end

  describe 'index.json (as admin)' do
    let(:limit) { nil }
    before do
      login_as(admin)
      get :index, params: {
        format: :json,
        query: {
          number_of_records: limit,
        },
      }
    end
    context 'with no params' do
      it 'returns success' do
        expect(response).to be_successful
      end
      it 'fetches all events by type' do
        events = JSON.parse(response.body)['application_events']
        expect(events).to have(12).items
      end
    end
    context 'with a limit of 2' do
      let(:limit) { 2 }
      it 'fetches all events by type' do
        events = JSON.parse(response.body)['application_events']
        expect(events).to have(4).items
      end
    end
  end
end
