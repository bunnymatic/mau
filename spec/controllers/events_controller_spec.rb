require 'spec_helper'

describe EventsController do

  include AuthenticatedTestHelper

  fixtures :users, :studios, :artist_infos, :roles, :roles_users, :events, :art_pieces

  render_views

  describe 'unauthorized' do
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

    describe '#show' do
      before do
        @event = Event.all.first
        get 'show', :id => events(:html_description).id
      end
      it { response.should be_success }
      it 'renders the event text properly' do
        assert_select 'p b', 'paragraph'
      end
      it 'renders the page links properly' do
        assert_select ".events_link a", /View.*\&raquo;/
        assert_select ".calendar_link a", /View.*\&raquo;/
      end
      it 'renders the event_url properly' do
        expected_url = events(:html_description).url
        assert_select ".url a[href=#{expected_url}]", expected_url.gsub(/https?:\/\//, '')
      end
      it 'renders the event_url properly' do
        expected_url = events(:html_description).url
        assert_select ".url a[href=#{expected_url}]", expected_url.gsub(/https?:\/\//, '')
      end

    end

  end

  describe 'authorized as an editor' do
    before do
      login_as :editor
    end
    context "admin_index" do
      before do
        get :admin_index
      end
      it_should_behave_like 'returns success'
      it "marks down the event content" do
        response.body.should_not include 'lt;p&gt;'
      end
    end

    context 'new' do
      before do
        get :new
      end
      it_should_behave_like 'returns success'
      it 'constructs a new event' do
        assigns(:event).should be_new_record
        assigns(:event).state.should eql 'CA'
      end
      it 'renders new_or_edit' do
        response.should render_template 'new_or_edit'
      end
    end

    context 'create' do
      let(:event_attrs) { FactoryGirl.attributes_for(:event) }
      before do
        EventMailer.stub(:event_added).and_return(double('deliverable', :deliver! => true))
        post :create, :event => event_attrs
      end
      it { response.should redirect_to events_path }
      it "saves a new event" do
        Event.where(:url => event_attrs[:url]).should be_present
      end
    end

    context 'update' do
      let (:event) { Event.last }
      before do
        put :update, :id => event, :event => { :title => 'new event title' }
      end
      it { response.should redirect_to admin_events_path }
      it "updates the title" do
        event.reload.title.should eql 'new event title'
      end
    end

    context 'destroy' do
      before do
        delete :destroy, :id => Event.last
      end
      it { response.should redirect_to events_path }
    end

    context 'edit' do
      before do
        get :edit, :id => Event.last
      end
      it_should_behave_like 'returns success'
      it 'pulls the event' do
        assigns(:event).should eql Event.last
      end
      it 'renders new_or_edit' do
        response.should render_template 'new_or_edit'
      end
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
