require 'rails_helper'

describe Admin::ApplicationEventsController do
  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:os_event) { FactoryGirl.create(:open_studios_signup_event, data: {user: 'artist'})}
  let(:generic_event) { FactoryGirl.create(:generic_event) }

  describe 'unauthorized #index' do
    before do
      get :index
    end
    it_should_behave_like 'not authorized'
  end
  describe 'index (as admin)', eventmachine: true do
    before do
      os_event
      generic_event
      login_as(admin)
      get :index
    end
    it 'returns success' do
      expect(response).to be_success
    end
    it 'fetches all events by type' do
      events = assigns(:events_by_type)
      expect(events).not_to be_empty
      expect(events.keys).to include 'GenericEvent'
      expect(events.keys).to include 'OpenStudiosSignupEvent'
      generics = events['GenericEvent']
      expect(generics.size).to eq(1)
      expect(generics.first.message).to eql generic_event.message
      oss = events['OpenStudiosSignupEvent']
      expect(oss.size).to eq(1)
      expect(oss.first.data).to eql(os_event.data)
    end
  end

end
