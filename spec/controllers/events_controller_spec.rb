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

    describe '#index' do
      context 'with params' do
        let(:first_event) { Event.published.first }
        let(:month_year_key) { first_event.starttime.strftime('%Y%m') }
        before do
          get :index, "m" => month_year_key
        end
        it 'sets current month if params m=current_month' do
          expect(assigns(:events).current).to eql month_year_key
        end
        it 'orders events by start date inverse' do
          expect(assigns(:events).map{|ev| ev.event.stime}).to be_monotonically_decreasing
        end

      end
      context '.json' do
        before do
          get :index, :format => 'json'
        end
        it_should_behave_like 'successful json'
        it 'returns json list of events' do
          j = JSON.parse(response.body)
          expect(j).to have_at_least(1).event
          expect(j.count).to eql Event.published.count
        end

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
      let(:event_attrs) do
        attrs = FactoryGirl.attributes_for(:event).merge({:artist_list => Artist.active.first.get_name})
        attrs.delete(:starttime)
        attrs.delete(:reception_starttime)
        attrs.delete(:endtime)
        attrs.delete(:reception_endtime)
        attrs[:start_time] = "12:00 PM"
        attrs[:start_date] = "21 January, 2013"
        attrs[:reception_start_time] = "12:00 PM"
        attrs[:reception_start_date] = "22 January, 2013"
        attrs[:end_time] = "12:00 PM"
        attrs[:end_date] = "21 February, 2013"
        attrs[:reception_end_time] = "1:00 PM"
        attrs[:reception_end_date] = "22 January, 2013"
        attrs
      end

      context 'with standard params' do
        before do
          EventMailer.stub(:event_added).and_return(double('deliverable', :deliver! => true))
          post :create, :event => event_attrs
        end
        it { response.should redirect_to events_path }
        it "saves a new event" do
          expect(Event.where(:url => event_attrs[:url])).to be_present
        end
        it 'adds the artist name to the event' do
          event = Event.where(:url => event_attrs[:url]).first!
          expect(event.description).to include Artist.active.first.get_name
        end
        it 'sets the starttime' do
          event = Event.where(:url => event_attrs[:url]).first!
          expect(event.starttime).to eql Time.zone.parse("21 January, 2013 12:00PM")
        end
        it 'sets the reception endtime' do
          event = Event.where(:url => event_attrs[:url]).first!
          expect(event.reception_endtime).to eql Time.zone.parse("22 January, 2013 1:00PM")
        end
      end
    end

    context 'update' do
      let (:event) { Event.last }
      let (:new_attrs) do
        attrs = {}
        attrs[:title] = 'new event title'
        attrs[:start_time] = "12:00 PM"
        attrs[:start_date] = "21 January, 2013"
        attrs[:reception_start_time] = "12:00 PM"
        attrs[:reception_start_date] = "22 January, 2013"
        attrs[:end_time] = "12:00 PM"
        attrs[:end_date] = "21 February, 2013"
        attrs[:reception_end_time] = "1:00 PM"
        attrs[:reception_end_date] = "22 January, 2013"
        attrs
      end
      before do
        put :update, :id => event, :event => new_attrs
      end
      it { response.should redirect_to admin_events_path }
      it "updates the title" do
        event.reload.title.should eql 'new event title'
      end
      it 'sets the starttime' do
        expect(event.reload.starttime).to eql Time.zone.parse("21 January, 2013 12:00PM")
      end
      it 'sets the reception endtime' do
        expect(event.reload.reception_endtime).to eql Time.zone.parse("22 January, 2013 1:00PM")
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
        assigns(:event).object.should eql Event.last
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
