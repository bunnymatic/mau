require 'spec_helper'

describe Admin::EventsController do

  let(:admin) { FactoryGirl.create(:artist, :admin) }
  let(:editor) { FactoryGirl.create(:artist, :editor) }

  let(:published_at) { Time.zone.now }
  let(:event) { FactoryGirl.create(:event, published_at: published_at) }

  [:index, :publish, :unpublish].each do |endpt|
    context "#{endpt} when not logged in" do
      before do
        get endpt, :id => 'whatever'
      end
      it_should_behave_like 'not authorized'
    end
  end

  describe 'authorized as an admin' do
    before do
      login_as admin
    end
    context "index" do
      before do
        get :index
      end
      it { expect(response).to be_success }
      it "marks down the event content" do
        expect(response.body).not_to include 'lt;p&gt;'
      end
    end
  end

  describe 'authorized as an editor' do
    before do
      login_as editor
    end

    context 'publish' do
      let(:published_at) { nil }
      it 'publishes the event' do
        ev = event
        expect{
          post :publish, :id => ev.id
          ev.reload
        }.to change(ev, :published_at)
      end
      it 'redirects to the event index' do
        post :publish, :id => event.id
        expect(response).to redirect_to admin_events_path
      end
    end
    context 'unpublish' do
      it 'unpublishes the event' do
        ev = event
        expect{
          post :unpublish, :id => ev.id
          ev.reload
        }.to change(ev, :published_at)
      end
      it 'redirects to the event index' do
        post :unpublish, :id => event.id
        expect(response).to redirect_to admin_events_path
      end

    end

  end
end
