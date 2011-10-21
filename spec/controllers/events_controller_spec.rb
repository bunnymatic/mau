require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

include AuthenticatedTestHelper

def get_event_params(opts={})
  { :title => gen_random_string(20),
    :description => gen_random_string(200),
    :starttime => Time.now + 1.day,
    :endtime => Time.now + 1.day + 2.hours,
    :venue => gen_random_string(20),
    :street => rand(1000),
    :city => 'san francisco'
  }.merge(opts)
end


describe EventsController do

  fixtures :users, :events, :roles

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
  end

  describe "#new" do
    integrate_views
    before do
      login_as(:jesseponce)
      get :new
    end
    it_should_behave_like 'event new or edit'
  end

  describe '#show' do
    it 'should redirect to index page with event id as a hash tag' do
      get :show, :id => Event.published.first.id
      response.should redirect_to(events_path + "##{Event.published.first.id}")
    end
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
      Event.any_instance.stubs(:url => 'whatever.com')
      Event.any_instance.stubs(:description => "# header\n\n##header2\n\n*doit*")
      get :index
    end
    it "returns success" do
      response.should be_success
    end
    it 'assigns only future published events' do
      assigns(:events).count.should == Event.future.published.count
    end
    it 'assigns only future published events keyed by month' do
      assigns(:events_by_month).values.flatten.count.should == Event.future.published.count
      assigns(:events_by_month).keys.sort.should == Event.future.published.map(&:starttime).map{|st| st.strftime("%B %Y")}.uniq.sort
    end
    it 'runs markdown on event description' do
      response.should have_tag('.desc h1', 'header')
      response.should have_tag('.desc h2', 'header2')
      response.should have_tag('.desc em', 'doit')
    end
    it 'makes sure the url includes http for the link' do
      response.should have_tag('a[href=http://whatever.com]', 'whatever.com')
    end
    it 'renders an anchor tag with the event id in each event' do
      Event.future.published.each do |ev|
        response.should have_tag(".events a[name=#{ev.id}]")
      end
    end
    it 'renders a break for each month with a header' do
      Event.future.published.map(&:starttime).map{|t| t.strftime("%B %Y")}.uniq.each do |month|
        response.should have_tag('.events h4.month', month)
      end
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
      response.should redirect_to(events_path)
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
      response.should redirect_to(events_path)
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
      login_as(:admin)
      get :admin_index
    end
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
      EventMailer.expects(:deliver_event)
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
end
