require 'spec_helper'

describe EventsController do

  include AuthenticatedTestHelper

  fixtures :users, :studios, :artist_infos, :roles, :roles_users, :events
  describe 'authorization' do
    [:edit, :new].each do |endpt|
      context "when not logged in, #{endpt}" do
        before do 
          get endpt
        end
        it_should_behave_like 'login required'
      end
    end
      
    [:admin_index, :publish, :unpublish].each do |endpt|
      context "#{endpt} when not logged in" do
        before do 
          get endpt
        end
        it_should_behave_like 'login required'
      end
      context "#{endpt} when logged in as nobody" do
        before do 
          login_as :noaddress
          get endpt
        end
        it_should_behave_like 'not authorized'
      end
    end
    
    context 'as an editor' do
      before do 
        login_as :editor
      end
      context "admin_index" do
        before do 
          get :admin_index
        end
        it_should_behave_like 'returns success'
      end
      context 'publish' do
        before do
          @event = events(:reception_full)
          @event.update_attribute('publish', nil)
        end
        it 'publishes the event' do
          expect{
            post :publish, :id => @event.id
            @event.reload
          }.to change(@event, :publish)
        end
        it 'redirects to the event index' do
          post :publish, :id => @event.id
          response.should redirect_to admin_events_path
        end
      end        
      context 'unpublish' do
        before do
          @event = events(:reception_full)
        end
        it 'unpublishes the event' do
          expect{
            post :unpublish, :id => @event.id
            @event.reload
          }.to change(@event, :publish)
        end
        it 'redirects to the event index' do
          post :unpublish, :id => @event.id
          response.should redirect_to admin_events_path
        end
        
      end
    end

  end
end
