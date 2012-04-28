require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

def get_event_params(opts={})
  { :title => gen_random_string(20),
    :description => gen_random_string(200),
    :starttime => Time.now + 1.day,
    :endtime => Time.now + 1.day + 2.hours,
    :reception_starttime => Time.now + 1.day + 1.hour,
    :venue => gen_random_string(20),
    :street => rand(1000),
    :city => 'san francisco'
  }.merge(opts)
end


describe EventsController do

  fixtures :users, :events, :roles, :art_pieces

  [:edit].each do |endpoint| 
    it "##{endpoint} should redirect to login if not logged in" do
      get endpoint
      response.should be_redirect
    end
  end
  [:unpublish, :publish, :admin_index].each do |endpoint|
    it "##{endpoint} requires admin - redirects to error if you're logged in as joe schmoe" do
      login_as(:jesseponce)
      get endpoint
      response.should redirect_to '/error'
    end
  end

  shared_examples_for 'event new or edit' do
    it "returns success" do
      response.should be_success
    end
    it "renders new or edit template" do
      response.should render_template 'new_or_edit'
    end
    it "does not include the publish checkbox" do
      assert_select("input#event_publish", false)
    end
    it 'has time fields for start/end and reception start/end' do
      assert_select('input#event_reception_starttime')
      assert_select('input#event_reception_endtime')
      assert_select('input#event_starttime')
      assert_select('input#event_endtime')
    end

  end

  describe "#new" do
    integrate_views
    before do
      login_as(:jesseponce)
      get :new
    end
    it_should_behave_like 'event new or edit'
  end

  describe "#edit" do
    integrate_views
    before do
      login_as(:jesseponce)
      @ev = Event.first
      get :edit, :id => @ev.id
    end
    it_should_behave_like 'event new or edit'
  end

  describe "#index" do
    integrate_views
    before do
      get :index
    end
    it 'returns success' do
      response.should be_success
    end
    it 'shows this month\'s events' do
      assigns(:events_by_month).should be_a_kind_of Hash
      assigns(:events_by_month).should have_key Time.now.strftime("%Y%m")
      assert_select('.events_by_month.current')
      assert_select('.event_nav li.by_month.current').each do |tag|
        tag.attributes['data-viskey'].should == Time.now.strftime('%Y%m')
      end
    end
    it 'has dom for all published events' do
      assert_select '.event_list .event', :count => Event.published.count
    end
    it 'has dom for all published event months' do
      assert_select '.event_list .events_by_month', :count => assigns(:events_by_month).count
    end
  end

  describe '#show' do
    integrate_views
    before do 
      Event.any_instance.stubs(:description => "# header\n\n##header2\n\n*doit*")
      get :show, :id => Event.published.all.last
    end
    it "returns success" do
      response.should be_success
    end
    it 'assigns only future published events' do
      assigns(:event).should == Event.published.all.last
    end
    it 'runs markdown on event description' do
      assert_select('.desc h1', 'header')
      assert_select('.desc h2', 'header2')
      assert_select('.desc em', 'doit')
    end
    it 'makes sure the url includes http for the link' do
      assert_select('.url a[href=http://www.example.com]', 'www.example.com')
    end
    it 'makes sure the url includes http for the links that don\'t start with http' do
      assert_select('.url a[href=http://www.example.com]', 'www.example.com')
    end
    it 'makes sure the url includes http for the links that do start with http' do
      assert_select('.url a[href=http://www.example.com]', 'www.example.com')
    end
  end

  describe "#publish" do
    before do
      @before_publish = Time.now()
      login_as(:admin)
      @ev = events(:future)
      get :publish, :id => @ev.id
    end
    it "redirects to index" do
      response.should redirect_to(admin_events_path)
    end
    it "flashes that the event has been published" do
      flash[:notice].should include "#{@ev.title} has been successfully published"
    end
    it "sets publish to now on that event" do
      @ev.reload
      @ev.publish.to_i.should be >= @before_publish.to_i
    end
    it "notifies the event submitter with an email" do
      EventMailer.expects(:deliver_event_published)
      @ev = events(:noendtime)
      get :publish, :id => @ev.id
    end

  end

  describe "#unpublish" do
    before do
      login_as(:admin)
      @ev = events(:published)
      get :unpublish, :id => @ev.id
    end
    it "redirects to index" do
      response.should redirect_to(admin_events_path)
    end
    it "flashes that the event has been unpublished" do
      flash[:notice].should include "#{@ev.title} has been successfully unpublished"
    end
    it "sets publish to nil on that event" do
      @ev.reload
      @ev.publish.should be_nil
    end
  end

  describe '#admin_index' do
    integrate_views
    before do
      Event.any_instance.stubs(:description => "# header\n\n##header2\n\n*doit*")
      login_as(:admin)
      get :admin_index
    end
    it_should_behave_like 'logged in as admin'
    it "returns sucess" do
      response.should be_success
    end
    it 'assigns all events if you are an admin' do
      assigns(:events).count.should == Event.count
    end
    it 'shows publish buttons' do
      assert_select("a[href=#{publish_event_path(Event.first)}]")
    end
    it 'shows unpublish buttons for published events' do
      assert_select("a[href=#{unpublish_event_path(Event.published.first)}]")
    end
    it 'runs markdown on event description' do
      assert_select('.desc h1', 'header')
      assert_select('.desc h2', 'header2')
      assert_select('.desc em', 'doit')
    end
    it 'makes sure the url includes http for the link' do
      assert_select('.url a[href=http://url.com]', 'url.com')
    end
    it 'makes sure the url includes http for the links that don\'t start with http' do
      assert_select('.url a[href=http://url.com]', 'url.com')
    end
    it 'makes sure the url includes http for the links that do start with http' do
      assert_select('.url a[href=http://www.example.com]', 'www.example.com')
    end
      
  end

  describe '#create' do
    before do
      login_as(:jesseponce)
    end
    it 'returns redirects to events index' do
      ev = get_event_params
      post :create, :event => ev
      response.should redirect_to(events_path)
    end
    it 'emails the system' do
      ev = get_event_params
      EventMailer.expects(:deliver_event_added)
      post :create, :event => ev
    end
    context 'with artists list' do
      integrate_views
      before do 
        login_as(:jesseponce)
        @ev = get_event_params({"artist_list" => 'quentin tarantino, joe blogs, artist1, pending'})
        post :create, :event => @ev
      end
      it 'creates an event' do
        Event.find_by_title(@ev[:title]).should be
      end
      it 'includes the submitter' do
        Event.find_by_title(@ev[:title]).user.should == users(:jesseponce)
      end
      it 'integrates artists links into the description' do
        ev = Event.find_by_title(@ev[:title])
        ev.description.should include '[artist1 Fixture]'
        ev.description.should include users(:artist1).get_share_link
        ev.description.should include '[joe blogs]'
        ev.description.should include users(:joeblogs).get_share_link
      end
      it 'only puts active artists into the description ' do
        ev = Event.find_by_title(@ev[:title])
        ev.description.should_not include "pending"
      end
    end
  end

  describe 'json' do
    integrate_views
    describe 'index' do
      before do
        get :index, :format => 'json'
      end
      it 'returns success' do
        response.should be_success
      end
      it 'returns json' do
        response.content_type.should == 'application/json'
      end
      it 'returns the right number of events' do
        j = JSON.parse(response.body)
        j.count.should == Event.published.count
        j.map{|ev| ev['event']}.each do |entry|
          entry.should have_key 'title'
          entry.should have_key 'starttime'
        end
      end
    end
  end

end
