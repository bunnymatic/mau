require 'spec_helper'

describe Admin::EventsController do

  include AuthenticatedTestHelper

  fixtures :users,:events, :roles_users

  [:index, :publish, :unpublish].each do |endpt|
    context "#{endpt} when not logged in" do
      before do
        get endpt
      end
      it_should_behave_like 'not authorized'
    end
  end

  describe 'authorized as an admin' do
    before do
      login_as :admin
    end
    context "index" do
      before do
        get :index
      end
      it_should_behave_like 'returns success'
      it "marks down the event content" do
        response.body.should_not include 'lt;p&gt;'
      end
    end
  end

  describe 'authorized as an editor' do
    before do
      login_as :editor
    end

    context 'publish' do
      before do
        @event = events(:reception_full)
        @event.update_attribute('published_at', nil)
      end
      it 'publishes the event' do
        expect{
          post :publish, :id => @event.id
          @event.reload
        }.to change(@event, :published_at)
      end
      it 'redirects to the event index' do
        post :publish, :id => @event.id
        expect(response).to redirect_to admin_events_path
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
        }.to change(@event, :published_at)
      end
      it 'redirects to the event index' do
        post :unpublish, :id => @event.id
        expect(response).to redirect_to admin_events_path
      end

    end

  end
end
