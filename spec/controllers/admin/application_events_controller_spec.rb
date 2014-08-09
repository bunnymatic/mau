require 'spec_helper'

describe Admin::ApplicationEventsController do
  fixtures :application_events, :users, :roles, :roles_users
  describe 'unauthorized #index' do
    before do
      get :index
    end
    it_should_behave_like 'not authorized'
  end
  describe 'index (as admin)' do
    before do
      login_as(:admin)
      get :index
    end
    it 'returns success' do
      expect(response).to be_success
    end
    it 'fetches all events by type' do
      events = assigns(:events_by_type)
      events.should_not be_empty
      events.keys.should include 'GenericEvent'
      events.keys.should include 'OpenStudiosSignupEvent'
      generics = events['GenericEvent']
      generics.should have(1).event
      generics.first.message.should eql 'something happened'
      oss = events['OpenStudiosSignupEvent']
      oss.should have(1).event
      oss.first.data.should eql({'user' => 'jesseponce'})
    end
  end

end
