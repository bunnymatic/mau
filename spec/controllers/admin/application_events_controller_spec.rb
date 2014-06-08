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
    render_views
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
    it 'renders all the events in sections' do
      assert_select '.singlecolumn .generic_events tr', :count => 1
      assert_select '.singlecolumn .open_studios_signup_events tr td a[href=/artists/jesseponce]', :count =>1
      assert_select '.singlecolumn .open_studios_signup_events tr', :count =>1
    end
  end

end
