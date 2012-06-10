require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

describe EventSubscribersController do
  fixtures :event_subscribers, :application_events, :users, :roles
  describe 'unauthorized' do
    describe '#index' do
      before do
        get :index
      end
      it_should_behave_like 'not authorized'
    end
  end
  describe 'authorized' do
    describe '#index' do
      integrate_views
      before do 
        login_as(:admin)
        get :index
      end
      it 'returns success' do
        response.should be_success
      end
      it 'assigns all subscribers' do
        subscribers = assigns(:subscribers)
        subscribers.count.should == EventSubscriber.count
        subscribers.map(&:event_type).sort.should == ['GenericEvent','OpenStudiosSignupEvent']
        subscribers.map(&:url).sort.should == ['http://example.com/generic','http://example.com/openstudios']
      end
      
    end
    
  end
  
end
